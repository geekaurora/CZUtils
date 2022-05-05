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
  
  public func write( block: @escaping () -> Void) {
    queue.async {
      block()
    }
  }
}
