import Foundation

/**
 CADisplayLink observer that observes FPS for FPS tests.
 */
public class CZFPSTestObserver {
  public static let shared = CZFPSTestObserver()
  
  public private(set) var fpsValues = [Double]()
  
  public init() {}
  
  public func start() {
    CADisplayLinkMonitor.shared.addListener(self)
  }
  
  public func stop() {
    CADisplayLinkMonitor.shared.removeListener(self)
  }
}

// MARK: - CADisplayLinkObserverProtocol

extension CZFPSTestObserver: CADisplayLinkObserverProtocol {
  public func handleUpdatedData(_ data: CZEventData?) {
    guard let displayLinkEventData = (data as? DisplayLinkEventData).assertIfNil,
          let fps = displayLinkEventData.fps.assertIfNil else {
      return
    }
    fpsValues.append(fps)
  }
}
