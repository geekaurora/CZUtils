import Foundation

/// Generic Array class with thread safety.
///
/// - Note: `Element` should be class type.
public class ThreadSafeArray<Element> {
  @ThreadSafe
  private var array = [Element]()
  
  public init() {}
  
  public var allObjects: [Element] {
    return _array.threadLock { $0 }
  }
  
  public var count: Int {
    return array.count
  }
  
  public var isEmpty: Bool {
    return array.isEmpty
  }
  
  public func append(_ element: Element) {
    _array.threadLock { value in
      value.append(element)
    }
  }
  
  public func remove(_ element: Element) {
    _array.threadLock { value in
      value.remove(element)
    }
  }
  
  public func contains(_ element: Element) -> Bool {
    return _array.threadLock { value in
      value.contains{ $0 as AnyObject === element as AnyObject }
    }
  }
}
