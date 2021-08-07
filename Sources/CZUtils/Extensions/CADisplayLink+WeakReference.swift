import UIKit

fileprivate var weakReferenceBox: CADisplayLinkWeakReferenceBox?

/**
 Exposes the helper method to create the displayLink being held weak reference.
 */
public extension CADisplayLink {
  /// Creates displayLink being held weak reference.
  /// - Parameters:
  ///   - target: The target that observes the displayLink, `target` is being held weak reference.
  ///   - selector: The selector to be called when the screen gets updated.
  /// - Returns: The displayLink being created.
  static func displayLinkWithWeakTarget(_ target: AnyObject,
                                        selector: Selector) -> CADisplayLink {
    // `weakReferenceBox` will be retained by the CADisplayLink instance.
    weakReferenceBox = CADisplayLinkWeakReferenceBox(target: target, selector: selector)
    return CADisplayLink(target: weakReferenceBox, selector: #selector(CADisplayLinkWeakReferenceBox.tick(_:)))
  }
}

// MARK: - Helper Class

fileprivate class CADisplayLinkWeakReferenceBox {
  private weak var target: AnyObject?
  private let selector: Selector
  
  init(target: AnyObject, selector: Selector) {
    self.target = target
    self.selector = selector
  }
  
  @objc func tick(_ displayLink: CADisplayLink) {
    if target != nil {
      let _ = target?.perform(selector)
    } else {
      displayLink.invalidate()
    }
  }
}
