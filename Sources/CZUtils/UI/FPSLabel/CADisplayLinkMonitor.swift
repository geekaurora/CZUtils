import UIKit

/// Observer that gets notified on rendering frame update of CADisplayLink.
public protocol CADisplayLinkObserverProtocol: CZDataEventListener {}

/// EventData that contains fps / displayLink.
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
  public static let shared = CADisplayLinkMonitor()
  
  /// Publisher that publishes frame update of CADisplayLink to observers.
  private let dataEventPublisher = CZDataEventPublisher<DisplayLinkEventData>()
  
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
    start()
  }

  deinit {
    stop()
  }
  
  // MARK: - Start / Stop
  
  public func start() {
    guard displayLink == nil else {
      return
    }
    //self.displayLink = CADisplayLink(target: self, selector: #selector(tick(_:)))
    self.displayLink = CADisplayLink.displayLinkWithWeakTarget(self, selector: #selector(tick(_:)))
    displayLink?.add(to: .main, forMode: .common)
  }
  
  public func stop() {
    guard displayLink != nil else {
      return
    }
    displayLink?.invalidate()
    self.displayLink = nil
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
    guard lastUpdateTimestamp != 0 else {
      lastUpdateTimestamp = displayLink.timestamp
      return
    }

    let timeDelta = displayLink.timestamp - lastUpdateTimestamp
    if timeDelta > 0.2 {
      print("[CZLog] timeDelta = \(timeDelta)")
    }
    lastUpdateTimestamp = displayLink.timestamp
  }
}
