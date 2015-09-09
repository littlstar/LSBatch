
#import <assert.h>
#import <batch/batch.h>

@interface MyDelegate : NSObject <BatchDelegate>
@property (nonatomic, readwrite) BOOL didFinish;
@property (nonatomic, readwrite) BOOL didAbort;
@property (nonatomic, readwrite) BOOL hasError;
@property (nonatomic, copy) NSError *err;
@end

@implementation MyDelegate
@synthesize didAbort;
- (void) batchDidFinish: (id <Batch>) batch { }
- (void) batch: (id <Batch>) batch didFailWithError: (id <NSObject>) error { }
- (void) batchDidAbort: (id <Batch>) batch {
  self.didAbort = YES;
}
@end


int
main (void) {
  __block MyDelegate *delegate = (MyDelegate.alloc.init);
  __block Batch *batch = [Batch new: 1];
  assert(batch);
  assert(1 == batch.concurrency);

  [batch delegate: delegate];

  __block BOOL worker1 = NO;
  __block BOOL worker2 = NO;
  [batch push: ^(BatchNextCallback next) {
    [batch abort];
    next(nil);
  }];

  assert(1 == batch.length);

  [batch push: ^(BatchNextCallback next) {
    worker2 = YES;
    next(nil);
  }];

  assert(2 == batch.length);

  [batch end: ^(NSError *err) {
    assert(nil == err);
    assert(NO == worker1);
    assert(NO == worker2);
    assert(YES == batch.isAborted);
    assert(YES == delegate.didAbort);
    exit(0);
  }];

  CFRunLoopRun();
  return 0;
}
