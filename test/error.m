
#import <assert.h>
#import <LSBatch/LSBatch.h>

@interface MyDelegate : NSObject <LSBatchDelegate>
@property (nonatomic, readwrite) BOOL hasError;
@property (nonatomic, copy) NSError *err;
@end

@implementation MyDelegate
@synthesize hasError;
@synthesize err;
- (void) batchDidFinish: (id <LSBatch>) batch {}
- (void) batchDidAbort: (id <LSBatch>) batch { }
- (void) batch: (id <LSBatch>) batch didFailWithError: (id <NSObject>) error {
  self.hasError = YES;
  self.err = (NSError *) error;
}
@end

int
main (void) {
  __block MyDelegate *delegate = (MyDelegate.alloc.init);
  __block LSBatch *batch = [LSBatch new: 1];
  assert(batch);
  assert(1 == batch.concurrency);

  [batch delegate: delegate];

  __block BOOL worker1 = NO;
  __block BOOL worker2 = NO;
  [batch push: ^(LSBatchNextCallback next) {
    NSMutableDictionary* details = (NSMutableDictionary.dictionary);
      [details setValue: @"error"
                 forKey: NSLocalizedDescriptionKey];
    NSError *err = [NSError errorWithDomain: @"test"
                                       code: 200
                                   userInfo: details];
    next(err);
  }];

  assert(1 == batch.length);

  [batch push: ^(LSBatchNextCallback next) {
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
