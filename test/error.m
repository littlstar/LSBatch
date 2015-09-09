
#import <assert.h>
#import <batch/batch.h>

@interface MyDelegate : NSObject <BatchDelegate>
@property (nonatomic, readwrite) BOOL hasError;
@property (nonatomic, copy) NSError *err;
@end

@implementation MyDelegate
@synthesize hasError;
@synthesize err;
- (void) batchDidFinish: (id <Batch>) batch {}
- (void) batchDidAbort: (id <Batch>) batch { }
- (void) batch: (id <Batch>) batch didFailWithError: (id <NSObject>) error {
  self.hasError = YES;
  self.err = (NSError *) error;
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
    NSMutableDictionary* details = (NSMutableDictionary.dictionary);
      [details setValue: @"error"
                 forKey: NSLocalizedDescriptionKey];
    NSError *err = [NSError errorWithDomain: @"test"
                                       code: 200
                                   userInfo: details];
    next(err);
  }];

  assert(1 == batch.length);

  [batch push: ^(BatchNextCallback next) {
    worker2 = YES;
    next(nil);
  }];

  assert(2 == batch.length);

  [batch end: ^(NSError *err) {
    assert(NO == worker1);
    assert(NO == worker2);
    assert(nil != err);
    assert([err.domain isEqualTo: @"test"]);
    assert(200 == err.code);
    assert([err.localizedDescription isEqualTo: @"error"]);
    assert(YES == delegate.hasError);
    exit(0);
  }];

  CFRunLoopRun();
  return 0;
}
