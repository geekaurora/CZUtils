import UIKit

class CADisplayLinkWeakReferenceBox {
  weak var target: AnyObject?
  
  init(target: AnyObject, selector sel: Selector) {
    self.target = target
  }
  
  @objc func tick(_ displayLink: CADisplayLink) {
    
  }
  
}

public extension CADisplayLink {
  class func displayLinkWithWeakTarget(target: AnyObject,
                                       selector: Selector) -> CADisplayLink {
    let weakReferenceBox = CADisplayLinkWeakReferenceBox(target: target, selector: selector)
    return CADisplayLink(target: weakReferenceBox, selector: #selector(CADisplayLinkWeakReferenceBox.tick(_:)))
    
  }
}
