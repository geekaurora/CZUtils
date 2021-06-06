import Foundation

/// Wrapper that only holds weak reference to containing element.
public class WeakWrapper<T: AnyObject> {
  
  weak var element: T?
  
  public init(_ element: T) {
    self.element = element
  }
}
