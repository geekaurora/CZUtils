import Foundation

/**
 ### Note

 1. Directly only read / write is thread safe. (Should be in the same lock session)
 ```
 let newCount = self.count
 ```

 Equivalent to:
 ```
 lock.lock()
 let newCount = self.count + 1
 lock.unlock()
 ```

 2. Directly read and write at the same time isn't thread safe. e.g.
 (Writing depends on the value from other lock session: value changes between read / write gap.)

 ```
 @ThreadSafe var count: Int = 0

 // Read / write of `self.count` aren't under the same lock session.
 self.count = self.count + 1

 ```

 Equivalent to:
 ```
 lock.lock()
 let newCount = self.count + 1
 lock.unlock()

 // .. If other thread changes `self.count` now, the result isn't correct.

 lock.lock()
 self.count = newCount
 lock.unlock()
 ```

 ### Usage
 ```
 public struct Foo {
   // Simple usage.
   @GCDSynchronized
   public var bar = Bar()

   // Optionally, pass in a label for debugging purposes.
   @GCDSynchronized("FooBarQueue")
   public var fooBar = FooBar()

   // When using @GCDSynchronized, specify a default value inline. If you don't have a default
   // inline value at compile-time, see `Advanced Usage` below.
   @GCDSynchronized
   public var intVar = 0

   @GCDSynchronized
   public var baz: Baz? = nil
 }
 ```
 */
@propertyWrapper
public final class GCDSynchronized<Value> {

  // MARK: Properties

  /// The backing value.
  ///
  /// - Warning: **DO NOT READ/WRITE WITHOUT USING GCD**
  private var value: Value

  /// The dispatch queue used to read/write the backing value.
  private let queue: DispatchQueue

  /// The flags to use when performing reads on the backing value.
  /// TODO(b/151460531): Follow up on https://bugs.swift.org/browse/SR-12479
  private let readFlags: DispatchWorkItemFlags = []

  /// The flags to use when performing writes on the backing value.
  private let writeFlags: DispatchWorkItemFlags

  // MARK: Initialization

  /// Wraps a value to ensure thread-safe reads and writes.
  ///
  /// - Parameters:
  ///   - value: The initial value of the wrapped value.
  ///   - queue: The dispatch queue to use when accessing the backing value. It is safe to use
  ///     concurrent queues.
  ///   - writeFlags: The flags to use when performing writes on the backing value.
  public init(
    wrappedValue value: Value, on queue: DispatchQueue,
    writeFlags: DispatchWorkItemFlags = [.barrier, .inheritQoS]
  ) {
    assert(
      queue != .main,
      "Do not use the main queue! We sync on the given queue, which is not safe to do on the main queue."
    )

    self.value = value
    self.queue = queue
    self.writeFlags = writeFlags.union(.barrier)  // Guarantee writes are exclusive.
  }

  /// Wraps a value to ensure thread-safe reads and writes.
  ///
  /// - Note: Will dispatch accessors on a *serial* dispatch queue that targets the given queue.
  ///   However, if the target queue is serial, then accessing the backing variable will also be
  ///   serial.
  ///
  /// - Parameters:
  ///   - value: The initial value of the wrapped value.
  ///   - label: The label of the dispatch queue to use when accessing the backing value.
  ///   - target: The queue to set as the target for the internal queue used when accessing the
  ///     backing value. Must be a concurrent queue if you want to retain concurrency when accessing
  ///     the backing variable.
  public convenience init(
    wrappedValue value: Value, _ label: String = .defaultLabel, target: DispatchQueue
  ) {
    let queue = DispatchQueue(label: label, target: target)
    self.init(wrappedValue: value, on: queue)
  }

  /// Wraps a value to ensure thread-safe reads and writes.
  ///
  /// - Note: Will dispatch accessors on a *serial* dispatch queue that targets the app global
  ///   queue with the given quality-of-service.
  ///
  /// - Parameters:
  ///   - value: The initial value of the wrapped value.
  ///   - label: The label of the dispatch queue to use when accessing the backing value.
  ///   - qos: The quality-of-service to use when accessing the backing value.
  public convenience init(
    wrappedValue value: Value, _ label: String = .defaultLabel, qos: DispatchQoS.QoSClass = .default
  ) {
    self.init(wrappedValue: value, label, target: .global(qos: qos))
  }

  // MARK: Accessors

  /// Accesses the backing value using GCD.
  public var wrappedValue: Value {
    // Synchronous reads.
    get {
      queue.sync(flags: readFlags) { self.value }
    }

    // Asynchronous barrier writes.
    set {
      assert(
        writeFlags.contains(.barrier),
        "Writes MUST be exclusive to avoid race conditions on concurrent queues.")
      queue.async(flags: writeFlags) {
        self.value = newValue
      }
    }
  }

  public var projectedValue: GCDSynchronized<Value> { self }
}

extension String {
  public static let defaultLabel = "com.GCDSynchronized"
}
