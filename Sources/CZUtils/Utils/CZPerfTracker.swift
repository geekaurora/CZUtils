import Foundation

/**
 Elegant performance tracker that records the duration of the specific execution.

 ### Usage
 ```
   CZPerfTracker.shared.reset()

   CZPerfTracker.shared.end("EventName")
 ```
 */
public class CZPerfTracker {
  public static let shared = CZPerfTracker()
  private var startTime: CFAbsoluteTime?

  public init() {}
  
  /// Starts tracking.
  public func reset() {
    self.startTime = CFAbsoluteTimeGetCurrent()
  }

  /// Ends and outputs the duration of the execution.
  @discardableResult
  public func end(_ label: String = "default") -> CFAbsoluteTime {
    guard let startTime = startTime.assertIfNil else {
      return 0
    }
    let duration = CFAbsoluteTimeGetCurrent() - startTime
    dbgPrint("[Perf Tracker] \(label) - duration = \(duration)")
    return duration
  }
}
