/**
 * `batch.h' - batch.m
 *
 * copyright (c) 2015 - Littlstar
 */

#import <Foundation/Foundation.h>

/**
 * Batch classes.
 */

@class Batch;
@class BatchWorker;

/**
 * Batch protocols.
 */

@protocol Batch;
@protocol BatchWorker;
@protocol BatchDelegate;

/**
 * Block callback notifying batch queue
 * that work is complete.
 */

typedef void (^BatchNextCallback)(id <NSObject> err);

/**
 * Block to represent batch work to be done.
 */

typedef void (^BatchWorkerCallback)(BatchNextCallback);

/**
 * Block that is called when all work is
 * complete or when an error occurs.
 */

typedef void (^BatchDoneCallback)(id <NSObject> err);

/**
 * Batch delegate protocol.
 */

@protocol BatchDelegate <NSObject>

/**
 * Called when batch did finish all work.
 */

- (void) batchDidFinish: (id <Batch>) batch;

/**
 * Called when batch encountered an error.
 */

- (void) batch: (id <Batch>) batch didFailWithError: (id <NSObject>) err;

/**
 * Called when batch work has been aborted.
 */

- (void) batchDidAbort: (id <Batch>) batch;
@end

/**
 * BatchWorker protcol.
 */

@protocol BatchWorker <NSObject>

/**
 * This batch worker block.
 */

@property (nonatomic, copy) BatchWorkerCallback work;

/**
 * Parent Batch class instance.
 */

@property (nonatomic, strong) id <Batch> parent;

/**
 * Predicate indicating of batch worker is complete.
 */

@property (nonatomic, readonly) BOOL isCompleted;

/**
 * Predicate indicating of batch worker is cancelled.
 */

@property (nonatomic, readonly) BOOL isAborted;

/**
 * Predicate indicating if batch worker is in progress.
 */

@property (nonatomic, readonly) BOOL isWorking;

/**
 * Create a new instance with a block
 */

+ (id) new: (BatchWorkerCallback) work;

/**
 * Run this workers work.
 */

- (instancetype) run: (BatchNextCallback) done;
@end

/**
 * Batch protocol.
 */

@protocol Batch <NSObject>

/**
 * This Batch instance UID.
 */

@property (nonatomic, readonly) const char *uid;

/**
 * Property indicating the concurrency of the
 * batch work to be completed. Defaults to `INFINITY'.
 */

@property (nonatomic, readwrite) unsigned int concurrency;

/**
 * Predicate indicating of batch worker is cancelled.
 */

@property (nonatomic, readonly) BOOL isAborted;

/**
 * Create a new instance with a known concurrency.
 */

+ (id) new: (unsigned int) concurrency;

/**
 * Sets batch delegate.
 */

- (instancetype) delegate: (id <BatchDelegate>) delegate;

/**
 * Push work on to the batch queue for later
 * execution.
 */

- (instancetype) push: (BatchWorkerCallback) work;

/**
 * Runs alls queued batch workers calling the
 * done callback when completed.
 */

- (instancetype) end: (BatchDoneCallback) done;

/**
 * Runs all queued batch workers.
 */

- (instancetype) run;

/**
 * Aborts batch work.
 */

- (instancetype) abort;

/**
 * Returns the length of batch queue.
 */

- (unsigned int) length;
@end

/**
 * BatchWorker class interface.
 */

@interface BatchWorker : NSObject <BatchWorker>
@end

/**
 * Batch class interface.
 */

@interface Batch : NSObject <Batch> {
unsigned int _length;
}

/**
 * Optional delegate object.
 */

@property (nonatomic, strong) id <BatchDelegate> delegate;

/**
 * Queued work.
 */

@property (nonatomic, strong) NSMutableArray *workers;

/**
 * Optional done callback.
 */

@property (copy) BatchDoneCallback done;

/**
 * Generates a Batch instance UID.
 */

+ (const char *) UID;
@end
