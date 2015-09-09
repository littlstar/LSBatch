/**
 * `batch.m' - batch.m
 *
 * copyright (c) 2015 - Littlstar
 */

#import <batch/batch.h>

static unsigned int BATCH_COUNTER = 0;

/**
 * BatchWorker class implementation.
 */

@implementation BatchWorker
@synthesize work;
@synthesize parent;
@synthesize isWorking;
@synthesize isAborted;
@synthesize isCompleted;

/**
 * Create a new instance with a block
 */

+ (id) new: (BatchWorkerCallback) work {
  BatchWorker *me = (BatchWorker.alloc.init);
  me.work = work;
  return (id) me;
}

/**
 * BatchWorker class initializer.
 */

- (instancetype) init {
  self = [super init];
  // public
  work = nil;
  parent = nil;
  isWorking = NO;
  isAborted = NO;
  isCompleted = NO;
  return self;
}

/**
 * Run this workers work.
 */

- (instancetype) run: (BatchNextCallback) done {
  self.work(done);
  return self;
}
@end

/**
 * Batch class implementation.
 */

@implementation Batch
@synthesize uid;
@synthesize isAborted;
@synthesize concurrency;

/**
 * Create a new instance with a known concurrency.
 */

+ (Batch *) new: (unsigned int) concurrency {
  Batch *me = (Batch.alloc.init);
  me.concurrency = concurrency;
  return me;
}

/**
 * Generates a Batch instance UID.
 */

+ (const char *) UID {
  char uid[BUFSIZ];
  memset(uid, 0, BUFSIZ);
  sprintf(uid, "com.batch.%d", ++BATCH_COUNTER);
  return (const char *) strdup(uid);
}

/**
 * Batch class initializer.
 */

- (instancetype) init {
  self = [super init];
  // public
  uid = (Batch.UID);
  isAborted = NO;
  concurrency = INFINITY;

  // private
  _done = nil;
  _length = 0;
  _delegate = nil;
  _workers = (NSMutableArray.alloc.init);
  return self;
}

/**
 * Sets batch delegate.
 */

- (instancetype) delegate: (id <BatchDelegate>) delegate {
  _delegate = delegate;
  return self;
}

/**
 * Push work on to the batch queue for later
 * execution.
 */

- (instancetype) push: (BatchWorkerCallback) work {
  BatchWorker *worker = [BatchWorker new: work];
  [_workers addObject: worker];
  return self;
}

/**
 * Runs alls queued batch workers calling the
 * done callback when completed.
 */

- (instancetype) end: (BatchDoneCallback) done {
  _done = done;
  return [self run];
}

/**
 * Runs all queued batch workers.
 */

- (instancetype) run {
  // block dependencies
  __block Batch *this = self;
  __block id <BatchDelegate> delegate = _delegate;
  __block unsigned int index = 0;
  __block unsigned int length = self.length;
  __block unsigned int pending = self.length;
  __block NSArray *workers = _workers.copy;
  __block unsigned int max = self.concurrency;
  __block SEL didFinish = @selector(batchDidFinish:);

  // no work to be done
  if (0 == pending) {
    if (delegate && [delegate respondsToSelector: didFinish]) {
      [delegate batchDidFinish: self];
    }
    if (_done != nil) _done(nil);
    return self;
  }

  // process
  typedef void (^NextBlock)(void);
  __block NextBlock next = nil;
  NextBlock process = ^{
    __block SEL didFailWithError = @selector(batch:didFailWithError:);
    __block SEL didAbort = @selector(batchDidAbort:);
    unsigned int i = index++;
    BatchWorker *work = workers[i];
    if (nil == work) return;
    else if ([this isAborted]) {
      if ([delegate respondsToSelector: didAbort]) {
        [delegate batchDidAbort: this];
      }
      if (_done != nil) _done(nil);
      return;
    }

    // run this work
    [work run: ^(NSError *err) {
      if ([this isAborted]) {
        if ([delegate respondsToSelector: didAbort]) {
          [delegate batchDidAbort: this];
        }
        if (_done != nil) _done(nil);
      } else if (err) {
        if ([delegate respondsToSelector: didFailWithError]) {
          [delegate batch: this didFailWithError: err];
        }
        if (_done != nil) _done(err);
      } else {
        if (--pending) {
          next();
        } else {
          if (delegate && [delegate respondsToSelector: didFinish]) {
            [delegate batchDidFinish: this];
          }
          if (_done != nil) _done(nil);
        }
      }
    }];
  };

  next = process;

  // initialize work!
  for (int i = 0; i < length; ++i) {
    if (i == max) break;
    else next();
  }

  return self;
}

/**
 * Aborts batch work.
 */

- (instancetype) abort {
  isAborted = YES;
  return self;
}

/**
 * Returns the length of batch queue.
 */

- (unsigned int) length {
  _length = (unsigned int) _workers.count;
  return _length;
}
@end
