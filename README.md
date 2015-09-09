# Batch

Batch control flow for Objective-C

## Installation

Batch is available through [CocoaPods](http://cocoapods.org/). To install it,
simply add the following line to your `Podfile`:

```ruby
pod "Batch"
```

Batch is also available through [clibs](https://github.com/clibs/clib).
To install it, simply run:

```sh
$ clib install littlstar/Batch
```

or add it to your `package.json` file:

```json
...
  "dependencies": {
    "littlstar/Batch": "*"
  }
...
```

## Usage

Batch provides mechanisms for adding block control flow and invoking
them with a set concurrency. Batch supports a delegate pattern as well.

Using Batch is as simple as providing a block for work to be done. The
block is a type defined with the following `typedef`:

```objc
typedef void (^BatchWorkerCallback)(BatchNextCallback);
```

Where `BatchNextCallback` is the callback block that should be called
when work is complete for the "worker block". It is a type defined with
the following `typedef`:

```objc
typedef void (^BatchNextCallback)(id <NSObject> err);
```

You can provide a callback block that is executed when all work is
complete. The block is a type defined with the following `typedef`:

```objc
typedef void (^BatchDoneCallback)(id <NSObject> err);
```

A simple worker example can constructed as such:

```objc
Batch *batch = [Batch new: INFINITY];

// queue work
[batch push: ^(BatchNextCallback next) {
  // do work here
  next(nil);
}];

// more work
[batch push: ^(BatchNextCallback next) {
  // more work here
  next(nil);
}];

// Execute worker blocks calling the provided
// callback block.
[batch end: ^(NSError *err) {
  if (err) {
    // handle error
  } else {
    // handle success
  }
}];
```

### Delegates

Batch defines the following `BatchDelegate` protocol:

```objc
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
```

## Documentation

Coming soon...

## License

MIT

