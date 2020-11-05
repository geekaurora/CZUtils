import Foundation

/// Generic Array class that only holds weak reference to containing elements with thread safety.
///
/// - Note: `Element` should be class type.
public class ThreadSafeWeakArray<Element> {
  @ThreadSafe
  private var weakArray = AnyThreadSafeWeakArray<AnyObject>()
  
  /// Indicates whether allow duplicate elements in the array.
  private var allowDuplicateElements: Bool
  
  public init(allowDuplicateElements: Bool = true) {
    self.allowDuplicateElements = allowDuplicateElements
  }
  
  public var allObjects: [Element] {
    return _weakArray.threadLock { value in
      value
        .allObjects
        .compactMap { $0 as? Element }
    }
  }
  
  public var count: Int {
    return weakArray.count
  }
  
  public var isEmpty: Bool {
    return weakArray.isEmpty
  }
  
  public func append(_ element: Element) {
    _weakArray.threadLock { value in
      if !allowDuplicateElements && value.allObjects.contains(where: { $0 as AnyObject === element as AnyObject }) {
        return
      }
      value.append(element as AnyObject)
    }
  }
  
  public func remove(_ element: Element) {
    _weakArray.threadLock { value in
      value.remove(element as AnyObject)
    }
  }
  
  public func contains(_ element: Element) -> Bool {
    return _weakArray.threadLock { value in
      value.contains(element as AnyObject)
    }
  }
}

/// Unerlying array class that only holds weak reference to containing elements with thread safety.
/// Constraint `Element` with `AnyObject` as weak variable has to be `AnyObject`.
private class AnyThreadSafeWeakArray<Element: AnyObject> {
  @ThreadSafe
  private var weakElementWrappers: [WeakWrapper<Element>] = []
  
  public init() {}
  
  public var allObjects: [Element] {
    return _weakElementWrappers.threadLock { value in
      value.compactMap { $0.element }
    }
  }
  
  public var count: Int {
    return _weakElementWrappers.threadLock { value in
      value
        .filter { $0.element !== nil }
        .count
    }
  }
  
  public var isEmpty: Bool {
    return count == 0
  }
  
  public func append(_ element: Element) {
    _weakElementWrappers.threadLock { value in
      value.append(WeakWrapper(element))
    }
  }
  
  public func remove(_ element: Element) {
    _weakElementWrappers.threadLock { value in
      value = value.filter { $0.element !== element }
    }
  }
  
  public func contains(_ element: Element) -> Bool {
    return _weakElementWrappers.threadLock { value in
      value.contains { $0.element === element }
    }
  }
}
