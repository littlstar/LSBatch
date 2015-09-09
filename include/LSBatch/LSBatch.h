/**
 * `batch.h' - batch.m
 *
 * copyright (c) 2015 - Littlstar
 */

#import <Foundation/Foundation.h>

/**
 * LSBatch classes.
 */

@class LSBatch;
@class LSBatchWorker;

/**
 * LSBatch protocols.
 */

@protocol LSBatch;
@protocol LSBatchWorker;
@protocol LSBatchDelegate;

/**
 * Block callback notifying batch queue
 * that work is complete.
 */

typedef void (^LSBatchNextCallback)(id <NSObject> err);

/**
 * Block to represent batch work to be done.
 */

typedef void (^LSBatchWorkerCallback)(LSBatchNextCallback);

/**
 * Block that is called when all work is
 * complete or when an error occurs.
 */

typedef void (^LSBatchDoneCallback)(id <NSObject> err);

/**
 * LSBatch delegate protocol.
 */

@protocol LSBatchDelegate <NSObject>

/**
 * Called when batch did finish all work.
 */

- (void) batchDidFinish: (id <LSBatch>) batch;

/**
 * Called when batch encountered an error.
 */

- (void) batch: (id <LSBatch>) batch didFailWithError: (id <NSObject>) err;

/**
 * Called when batch work has been aborted.
 */

- (void) batchDidAbort: (id <LSBatch>) batch;
@end

/**
 * LSBatchWorker protcol.
 */

@protocol LSBatchWorker <NSObject>

/**
 * This batch worker block.
 */

@property (nonatomic, copy) LSBatchWorkerCallback work;

/**
 * Parent LSBatch class instance.
 */

@property (nonatomic, strong) id <LSBatch> parent;

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

+ (id) new: (LSBatchWorkerCallback) work;

/**
 * Run this workers work.
 */

- (instancetype) run: (LSBatchNextCallback) done;
@end

/**
 * LSBatch protocol.
 */

@protocol LSBatch <NSObject>

/**
 * This LSBatch instance UID.
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

- (instancetype) delegate: (id <LSBatchDelegate>) delegate;

/**
 * Push work on to the batch queue for later
 * execution.
 */

- (instancetype) push: (LSBatchWorkerCallback) work;

/**
 * Runs alls queued batch workers calling the
 * done callback when completed.
 */

- (instancetype) end: (LSBatchDoneCallback) done;

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
 * LSBatchWorker class interface.
 */

@interface LSBatchWorker : NSObject <LSBatchWorker>
@end

/**
 * LSBatch class interface.
 */

@interface LSBatch : NSObject <LSBatch> {
unsigned int _length;
}

/**
 * Optional delegate object.
 */

@property (nonatomic, strong) id <LSBatchDelegate> delegate;

/**
 * Queued work.
 */

@property (nonatomic, strong) NSMutableArray *workers;

/**
 * Optional done callback.
 */

@property (copy) LSBatchDoneCallback done;

/**
 * Generates a LSBatch instance UID.
 */

+ (const char *) UID;
@end
