import Foundation

/**
 Property wrapper that ensures variable thread safe.
 
 - Note: thread safety requires mutex lock through all operations, not just read/write.
 e.g.
 let array = someArray
 sleep(10)
 array.append(1)
 
 In the above code, if array gets mutated by other thread, `array.append(1)` result will be wrong.
 
 TODO: figure out how to ensure thread safety after read and before write, given `@propertyWrapper`
 currently only supports custom get/set.
 */
@propertyWrapper
public struct ThreadSafe<T> {
  private var value: T
  private let lock = SimpleThreadLock()
  
  public init(wrappedValue: T) {
    value = wrappedValue
  }
  
  public var wrappedValue: T {
    get {
      return lock.execute {
        value
      }
    }
    set {
      lock.execute {
        value = newValue
      }
    }
  }
  
  public var projectedValue: T {
    get {
      return value
    }
    set {
      value = newValue
    }
  }
  
  /**
   TODO:
   In ThreadSafe(wrappedValue: count).execute {},
   `ThreadSafe(wrappedValue: count)` returns immutable value, so need to figure out how to mutate.
   */
  public func execute(_ execution: (T) -> Void) {
    lock.execute {
      execution(value)
    }
  }
  
  public func test() {}
  
}
