# LSBatch

LSBatch control flow for Objective-C

## Installation

LSBatch is available through [CocoaPods](http://cocoapods.org/). To install it,
simply add the following line to your `Podfile`:

```ruby
pod "LSBatch"
```

LSBatch is also available through [clibs](https://github.com/clibs/clib).
To install it, simply run:

```sh
$ clib install littlstar/LSBatch
```

or add it to your `package.json` file:

```json
...
  "dependencies": {
    "littlstar/LSBatch": "*"
  }
...
```

## Usage

LSBatch provides mechanisms for adding block control flow and invoking
them with a set concurrency. LSBatch supports a delegate pattern as well.

Using LSBatch is as simple as providing a block for work to be done. The
block is a type defined with the following `typedef`:

```objc
typedef void (^LSBatchWorkerCallback)(LSBatchNextCallback);
```

Where `LSBatchNextCallback` is the callback block that should be called
when work is complete for the "worker block". It is a type defined with
the following `typedef`:

```objc
typedef void (^LSBatchNextCallback)(id <NSObject> err);
```

You can provide a callback block that is executed when all work is
complete. The block is a type defined with the following `typedef`:

```objc
typedef void (^LSBatchDoneCallback)(id <NSObject> err);
```

A simple worker example can constructed as such:

```objc
LSBatch *batch = [LSBatch new: INFINITY];

// queue work
[batch push: ^(LSBatchNextCallback next) {
  // do work here
  next(nil);
}];

// more work
[batch push: ^(LSBatchNextCallback next) {
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

LSBatch defines the following `LSBatchDelegate` protocol:

```objc
@protocol LSBatchDelegate <NSObject>

// Called when batch did finish all work.
- (void) batchDidFinish: (id <LSBatch>) batch;

// Called when batch encountered an error.
- (void) batch: (id <LSBatch>) batch didFailWithError: (id <NSObject>) err;

// Called when batch work has been aborted.
- (void) batchDidAbort: (id <LSBatch>) batch;
@end
```

## Documentation

Coming soon...

## License

MIT
