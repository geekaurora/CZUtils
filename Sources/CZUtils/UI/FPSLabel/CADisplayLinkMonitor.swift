import UIKit

/// Delegate that gets notified on display frame update of CADisplayLink.
public protocol CADisplayLinkMonitorDelegate: class {
  func displayFrameDidUpdate(link: CADisplayLink, fps: Double?)
}

/// Monitor that monitors each display frame update of CADisplayLink.
@objc
public class CADisplayLinkMonitor: NSObject {
  public weak var delegate: CADisplayLinkMonitorDelegate?
  
  private var link: CADisplayLink!
  private var lastTime: TimeInterval = 0
  private var frames: Int = 0
  private var shouldNotifyEachFrameUpdate: Bool
  
  /// Initialize CADisplayLinkMonitor.
  ///
  /// - Parameter shouldNotifyEachFrameUpdate: Indicates whether notify delegate with each frame update, even with no fps data. Defaults to false.
  ///
  public init(shouldNotifyEachFrameUpdate: Bool = false) {
    self.shouldNotifyEachFrameUpdate = shouldNotifyEachFrameUpdate
    super.init()
    
    self.link = CADisplayLink(target: self, selector: #selector(tick(_:)))
    link.add(to: .main, forMode: .common)
  }

  deinit {
    link.invalidate()
  }
  
  // MARK: - CADisplayLink
  
  @objc func tick(_ link: CADisplayLink) {
    var fps: Double?
    defer {
      if shouldNotifyEachFrameUpdate || fps != nil {
        delegate?.displayFrameDidUpdate(link: link, fps: fps)
      }
    }
    
    guard lastTime != 0 else {
      lastTime = link.timestamp
      return
    }
    
    frames += 1
    let timeDelta = link.timestamp - lastTime
    if timeDelta < 1 {
      return
    }
    
    lastTime = link.timestamp
    fps = Double(frames) / Double(timeDelta)
    frames = 0
  }
}
