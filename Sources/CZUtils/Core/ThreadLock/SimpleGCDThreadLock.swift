import Foundation

/// Generic thread lock that is on top of a serial queue.
public class SimpleGCDThreadLock {
  private let queue = DispatchQueue(label: "com.thread.mutexLock")
  
  /// Executes `block` with read lock.
  @discardableResult
  public func read<T>(_ block: @escaping () -> T?) -> T?  {
    return queue.sync { () -> T? in
      return block()
    }
  }
  
  /// Executes `block` with write lock asynchronously.
  /// - Note: As the underlying queue is serial, even write asynchronously, succeeding read execution will execute after the write execution.
  /// This ensures the correctness and async write performance (no waiting for writes).
  @discardableResult
  public func write<T>(isAsync: Bool = true, block: @escaping () -> T?) -> T? {
    if isAsync {
      queue.async { _ = block() }
      return nil
    } else {
      return queue.sync {() -> T? in
        return block()
      }
    }
  }
}
