
#import <assert.h>
#import <LSBatch/LSBatch.h>

@interface MyDelegate : NSObject <LSBatchDelegate>
@property (nonatomic, readwrite) BOOL didFinish;
@property (nonatomic, readwrite) BOOL didAbort;
@property (nonatomic, readwrite) BOOL hasError;
@property (nonatomic, copy) NSError *err;
@end

@implementation MyDelegate
@synthesize didFinish;
@synthesize didAbort;
@synthesize hasError;
@synthesize err;

- (id) init {
  [super init];
  self.didFinish = NO;
  self.didAbort = NO;
  self.hasError = NO;
  self.err = nil;
  return self;
}

- (void) batchDidFinish: (id <LSBatch>) batch {
  self.didFinish = YES;
}

- (void) batch: (id <LSBatch>) batch didFailWithError: (id <NSObject>) error {
  self.hasError = YES;
  self.err = (NSError *) error;
}

- (void) batchDidAbort: (id <LSBatch>) batch {
  self.didAbort = YES;
}

@end

int
main (void) {
  __block MyDelegate *delegate = (MyDelegate.alloc.init);
  LSBatch *batch = [LSBatch new: 2];

  assert(batch);
  assert(2 == batch.concurrency);

  // set delegate
  [batch delegate: delegate];

  __block BOOL worker1 = NO;
  __block BOOL worker2 = NO;
  __block BOOL worker3 = NO;
  __block BOOL worker4 = NO;

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

  [batch push: ^(LSBatchNextCallback next) {
    worker3 = YES;
    next(nil);
  }];

  assert(3 == batch.length);

  [batch push: ^(LSBatchNextCallback next) {
    worker4 = YES;
    next(nil);
  }];

  assert(4 == batch.length);

  [batch end: ^(NSError *err) {
    assert(nil == err);
    assert(worker1);
    assert(worker2);
    assert(worker3);
    assert(worker4);
    assert(delegate.didFinish);
    exit(0);
  }];

  CFRunLoopRun();
  return 0;
}
