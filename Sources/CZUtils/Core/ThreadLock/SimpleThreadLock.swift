import Foundation

/// Convenience mutex lock that automatically unlocks when completes the execution.
open class SimpleThreadLock: NSRecursiveLock {
  public func execute<T>(_ execution: () -> T)  -> T {
    lock()
    defer {
      unlock()
    }
    return execution()
  }
}
