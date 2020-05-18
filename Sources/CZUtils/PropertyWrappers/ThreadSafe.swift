import Foundation

/**
 Property wrapper that ensures variable thread safe.
 
 ### Usage
 
 - Definition with @ThreadSafe annotation
 ```
  @ThreadSafe var count: Int = 0
 ```
 
 - Read with mutexLock: (simply refer to `count`)
 ```
  let a = count
 ```
 
 - Write with mutexLock: (execute with `mutexLock` closure, prefix _ to access wrapper)
 ```
   _count.threadLock { count in
    count += 1
   }
 ```
 */
@propertyWrapper
public struct ThreadSafe<T> {
  public typealias Block = (T) -> Void
  private var value: T
  private let lock = SimpleThreadLock()
  
  public init(wrappedValue: T) {
    value = wrappedValue
  }
  
  public var wrappedValue: T {
    get {
      return lock.execute { value }
    }
    set {
      lock.execute { value = newValue }
    }
  }
  
  public var projectedValue: T {
    get { return value }
    set { value = newValue }
  }
  
  /// MutexLock function  with thread safe to execute `execution` closure.
  ///
  ///  e.g.
  ///  - Definition with @ThreadSafe annotation
  ///   @ThreadSafe var count: Int = 0
  ///
  ///  - Read with mutexLock: (simply refer to `count`)
  ///     let a = count
  ///
  ///  - Write with mutexLock: (execute with `mutexLock` closure)
  ///    _count.mutexLock { count in
  ///      count += 1
  ///  }
  ///
  /// - Parameter execution: The closure to execute, with mutable wrappedValue.
  public mutating func threadLock<U>(_ execution: (inout T) -> U) -> U {
    return lock.execute {
      execution(&value)
    }
  }
}
