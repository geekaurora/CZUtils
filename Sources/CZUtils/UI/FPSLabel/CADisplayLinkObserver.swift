import UIKit

/// Delegate that gets notified on rendering frame update of CADisplayLink.
public protocol CADisplayLinkObserverDelegate: class {
  func displayFrameDidUpdate(displayLink: CADisplayLink, fps: Double?)
}

/// Observer that observes each rendering frame update of CADisplayLink.
@objc
public class CADisplayLinkObserver: NSObject {
  /// Delegate that gets notified on display frame update of CADisplayLink.
  public weak var delegate: CADisplayLinkObserverDelegate?
  
  private var displayLink: CADisplayLink!
  private var lastUpdateTimestamp: TimeInterval = 0
  private var updatedFrames: Int = 0
  private var shouldNotifyEachFrameUpdate: Bool
  
  /// Initialize CADisplayLinkObserver.
  ///
  /// - Parameter shouldNotifyEachFrameUpdate: Indicates whether notify delegate on each frame update, even with no fps data. Defaults to false.
  ///
  public init(shouldNotifyEachFrameUpdate: Bool = false) {
    self.shouldNotifyEachFrameUpdate = shouldNotifyEachFrameUpdate
    super.init()
    
    //self.displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
    self.displayLink = CADisplayLink.displayLinkWithWeakTarget(self, selector: #selector(tick(_:)))
    displayLink.add(to: .main, forMode: .common)
  }

  deinit {
    displayLink.invalidate()
  }
  
  // MARK: - CADisplayLink
  
  @objc func tick(_ displayLink: CADisplayLink) {
    var fps: Double?
    defer {
      if shouldNotifyEachFrameUpdate || fps != nil {
        delegate?.displayFrameDidUpdate(displayLink: displayLink, fps: fps)
      }
    }
    
    guard lastUpdateTimestamp != 0 else {
      lastUpdateTimestamp = displayLink.timestamp
      return
    }
    
    updatedFrames += 1
    let timeDelta = displayLink.timestamp - lastUpdateTimestamp
    if timeDelta < 1 {
      return
    }
    
    lastUpdateTimestamp = displayLink.timestamp
    fps = Double(updatedFrames) / Double(timeDelta)
    updatedFrames = 0
  }
}
