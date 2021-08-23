import UIKit

/// Observer that gets notified on rendering frame update of CADisplayLink.
public protocol CADisplayLinkObserverProtocol: CZDataEventListener {
}

public struct DisplayLinkEventData: CZEventData {
  public let displayLink: CADisplayLink?
  public let fps: Double?
  
  public init(displayLink: CADisplayLink?, fps: Double?) {
    self.displayLink = displayLink
    self.fps = fps
  }
}

/// Monitor that observes each rendering frame update of CADisplayLink.
@objc
public class CADisplayLinkMonitor: NSObject {
  /// Publisher that publishes frame update of CADisplayLink to observers.
  private var dataEventPublisher = CZDataEventPublisher()
  
  private var displayLink: CADisplayLink?
  private var lastUpdateTimestamp: TimeInterval = 0
  private var updatedFrames: Int = 0
  private var shouldNotifyEachFrameUpdate: Bool
  
  /// Initialize CADisplayLinkMonitor.
  ///
  /// - Parameter shouldNotifyEachFrameUpdate: Indicates whether notify delegate on each frame update, even with no fps data. Defaults to false.
  ///
  public init(shouldNotifyEachFrameUpdate: Bool = false) {
    self.shouldNotifyEachFrameUpdate = shouldNotifyEachFrameUpdate
    super.init()
    
    //self.displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
    self.displayLink = CADisplayLink.displayLinkWithWeakTarget(self, selector: #selector(tick(_:)))
    displayLink?.add(to: .main, forMode: .common)
  }

  deinit {
    displayLink?.invalidate()
  }
  
  // MARK: - Publisher
  
  public func addListener(_ listener: CADisplayLinkObserverProtocol) {
    dataEventPublisher.addListener(listener)
  }
  
  public func removeListener(_ listener: CADisplayLinkObserverProtocol) {
    dataEventPublisher.removeListener(listener)
  }
  
  // MARK: - CADisplayLink
  
  @objc func tick(_ displayLink: CADisplayLink) {
    var fps: Double?
    defer {
      if shouldNotifyEachFrameUpdate || fps != nil {
        let displayLinkEventData = DisplayLinkEventData(displayLink: displayLink, fps: fps)
        dataEventPublisher.publishDataChange(displayLinkEventData)
        
        // delegate?.displayFrameDidUpdate(displayLink: displayLink, fps: fps)
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
