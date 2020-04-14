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
public struct ThreadSafe {
  private var value: Int
  private let lock = SimpleThreadLock()
  
  public typealias ExecutionBlock = () -> Void
  // private var executionBlock: ExecutionBlock!
  
  public init(wrappedValue: Int) {
    value = wrappedValue
  }
  
  public var wrappedValue: Int {
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
  
  public var projectedValue: ExecutionBlock {
    mutating get {
      //let executionBlock = ExecutionBlock()
      return @escaping {
        self.value += 1
      }
    }
//    set {
//      value = newValue
//    }
  }
  
  /**
   TODO:
   In ThreadSafe(wrappedValue: count).execute {},
   `ThreadSafe(wrappedValue: count)` returns immutable value, so need to figure out how to mutate.
   */
  public func execute(_ execution: (Int) -> Void) {
    lock.execute {
      execution(value)
    }
  }
  
  public func test() {}
  
}
