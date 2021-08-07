import Foundation

/**
 Proxy that forwards method messages to underlying `target`, which  holds weak reference to `target`.

 - warning: If `target` is nil, `forwardingTarget(for: Selector)` will crash because `CZWeakProxy` won't handle the selector.
 - TODO: Add `deallocateBlock` to handle when `targets` gets deallocated.
 
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
