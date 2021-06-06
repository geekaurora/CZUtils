import Foundation

/// Thead-safe HashTable that only holds weak reference to containing items.
/// - Note: The functionality is similar to `NSSet` that each object has unique hash value.
public class ThreadSafeHashTable<ObjectType> : NSObject where ObjectType : AnyObject {
  
  private var items = NSHashTable<ObjectType>.weakObjects()
  private let mutexLock = SimpleThreadLock()
  
  public var count: Int {
    return mutexLock.execute {
      items.count
    }
  }
  
  public var allObjects: [ObjectType] {
    return mutexLock.execute {
      return items.allObjects
    }
  }
  
  public func add(_ item: ObjectType) {
    mutexLock.execute {
      items.add(item)
    }
  }
  
  public func remove(_ item: ObjectType) {
    mutexLock.execute {
      items.remove(item)
    }
  }
  
  public func contains(_ item: ObjectType) -> Bool {
    return mutexLock.execute {
      items.contains(item)
    }
  }
}
