
#import <assert.h>
#import <LSBatch/LSBatch.h>

int
main (void) {
  LSBatch *batch = [LSBatch new: 1];
  assert(batch);
  assert(1 == batch.concurrency);

  __block BOOL worker1 = NO;
  __block BOOL worker2 = NO;
  [batch push: ^(LSBatchNextCallback next) {
    worker1 = YES;
    next(nil);
  }];

  assert(1 == batch.length);

  [batch push: ^(LSBatchNextCallback next) {
    worker2 = YES;
    next(nil);
  }];

  assert(2 == batch.length);

  [batch end: ^(NSError *err) {
    assert(nil == err);
    assert(worker1);
    assert(worker2);
    exit(0);
  }];

  CFRunLoopRun();
  return 0;
}
