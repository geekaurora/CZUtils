import Foundation

/// Generic Array class with thread safety.
///
/// - Note: `Element` should be class type.
public class ThreadSafeArray<Element> {
  @ThreadSafe
  private var array = [Element]()
  /// Indicates whether allow duplicate elements in the array.
  private var allowDuplicates: Bool
  
  public init(allowDuplicates: Bool = true) {
    self.allowDuplicates = allowDuplicates
  }
  
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
      if !allowDuplicates && value.contains(where: { $0 as AnyObject === element as AnyObject }) {
        return
      }
      value.append(element)
    }
  }
  
  public func remove(_ element: Element) {
    _array.threadLock { value in
      value.remove(element)
    }
  }  
  
  /// Removes all elements from the array.
  ///
  /// - Parameter keepCapacity: Indicates whether to keep the existing capacity of the array after removing its elements. Defaults to false.
  public func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _array.threadLock { value in
      value.removeAll(keepingCapacity: keepCapacity)
    }
  }
  
  public func contains(_ element: Element) -> Bool {
    return _array.threadLock { value in
      value.contains {
        $0 as AnyObject === element as AnyObject
      }
    }
  }
}
