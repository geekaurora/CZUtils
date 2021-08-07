import UIKit

/**
 Proxy that forwards method message to underlying `target`, which  holds weak reference to `target`.
 
 ### Usage
 ```
 displayLink = CADisplayLink(target: CZWeakProxy(target: self),
 selector: #selector(didRefresh(dpLink:)))
 ```
 */
public class CZWeakProxy: NSObject {
  private weak var target: NSObjectProtocol?
  
  public init(target: NSObjectProtocol) {
    self.target = target
    super.init()
  }
  
  public override func responds(to aSelector: Selector!) -> Bool {
    let res = (target?.responds(to: aSelector) ?? false) || super.responds(to: aSelector)
    return res
  }
  
  public override func forwardingTarget(for aSelector: Selector!) -> Any? {
    return target
  }
}

/**
 Exposes the helper method to create the displayLink being held weak reference.
 
 Main runloop retains CADisplayLink object before `displayLink.invalidate()` gets called.
 */
public extension CADisplayLink {
  /// Creates displayLink being held weak reference.
  /// - Parameters:
  ///   - target: The target that observes the displayLink, `target` is being held weak reference.
  ///   - selector: The selector to be called when the screen gets updated.
  /// - Returns: The displayLink being created.
  static func displayLinkWithWeakTarget(_ target: NSObjectProtocol,
                                        selector: Selector) -> CADisplayLink {
    // `weakReferenceBox` will be retained by the CADisplayLink instance.
    
    return CADisplayLink(
      target: CZWeakProxy(target: target),
      selector: selector)
    
//    let weakReferenceBox = CADisplayLinkWeakReferenceBox(target: target, selector: selector)
//    return CADisplayLink(
//      target: weakReferenceBox,
//      selector: #selector(CADisplayLinkWeakReferenceBox.tick(_:)))
  }
}

// MARK: - Helper Class

fileprivate class CADisplayLinkWeakReferenceBox {
  private weak var target: NSObjectProtocol?
  private let selector: Selector
  
  init(target: NSObjectProtocol, selector: Selector) {
    self.target = target
    self.selector = selector
  }
  
  @objc func tick(_ displayLink: CADisplayLink) {
    if target != nil {
      let _ = target?.perform(selector, with: displayLink)
    } else {
      // Removing the display link from all run loop modes causes it to be released
      // by the run loop. The display link also releases the target.
      displayLink.invalidate()
    }
  }
}
