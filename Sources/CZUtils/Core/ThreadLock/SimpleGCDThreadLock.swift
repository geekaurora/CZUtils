import Foundation

/// Generic thread lock that is on top of a serial queue.
public class SimpleGCDThreadLock {
  private let queue = DispatchQueue(label: "com.thread.mutexLock")
  
  @discardableResult
  public func read<T>(_ block: @escaping () -> T?) -> T?  {
    return queue.sync { () -> T? in
      return block()
    }
  }
  
  @discardableResult
  public func write<T>(isAsync: Bool = true, block: @escaping () -> T?) -> T? {
    if isAsync {
      queue.async { _ = block() }
      return nil
    } else {
      return queue.sync(flags: .barrier) {() -> T? in
        return block()
      }
    }
  }
}
