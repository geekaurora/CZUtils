import Foundation

/**
 Property wrapper that ensures variable thread safe.
 
 ### Usage
 ```
  @ThreadSafe var count: Int = 0
  let a = count
   _count.threadLock { count in
    count += 1
   }
 ```
 
- Note: Directly assigning value to `count` doesn't guarantee thread safety. e.g.
 ```
 @ThreadSafe var count: Int = 0
 
 count = 1
 var count2 = count
 count2  += 10
 
 // It's possible to miss value changing for `count` if the result is based on`count2`.
 count += 1
 count = count2 + 1
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
      // `get` is protected by thread lock - thread safe when get with self.propertyName.
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
