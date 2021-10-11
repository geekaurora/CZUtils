import Foundation

/**
 Timer class that only holds the weak reference to its parent target.
 */
public class CZWeakTimer: NSObject {
  private var underlyingTimer: Timer?
  private weak var weakTarget: AnyObject?
  private var selector: Selector
  
  public override init() {
    fatalError("Should call designated initializer.")
  }
  
  public class func scheduledTimer(timeInterval: TimeInterval,
                                   target: Any,
                                   selector: Selector,
                                   userInfo: Any?,
                                   repeats: Bool) -> Timer? {
    let weakTimer = CZWeakTimer(
      timeInterval: timeInterval,
      target: target,
      selector: selector,
      userInfo: userInfo,
      repeats: repeats)
    weakTimer.underlyingTimer?.fire()
    return weakTimer.underlyingTimer
  }
  
  public init(timeInterval: TimeInterval,
              target: Any,
              selector: Selector,
              userInfo: Any?,
              repeats: Bool) {
    self.weakTarget = target as AnyObject
    self.selector = selector
    super.init()
    
    underlyingTimer = Timer(
      timeInterval: timeInterval,
      target: self,
      selector: #selector(timerTick(_:)),
      userInfo: userInfo,
      repeats: repeats)
  }
  
  @objc
  func timerTick(_ timer: Timer) {
    guard weakTarget != nil else {
      // If the timer's parent `target` is released, invalidate and release the timer.
      timer.invalidate()
      underlyingTimer = nil
      return
    }
    // Otherwise, perform the `selector` of the `target`.
    let _ = weakTarget?.perform(selector, with: timer)
  }
}
