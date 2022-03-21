import Foundation

/**
 Elegant performance tracker that records the durations for the specified events.
 
 ### Usage
 ```
 CZPerfTracker.shared.beginTracking(event: "YourEvent")
 
 CZPerfTracker.shared.endTracking(event: "YourEvent")
 ```
 */
public class CZPerfTracker {
  public static let shared = CZPerfTracker()
  
  public enum Constant {
    public static let event = "defaultEvent"
  }
  private lazy var startDateMap = [String: Date]()
  
  public init() {}
  
  /// Records start date for `event`.
  /// - Note: The existing start date will be overriden if has the same `event` as the current call.
  public func beginTracking(event: String = Constant.event) {
    startDateMap[event] = Date()
  }
  
  /// Ends and outputs the duration of the execution.
  @discardableResult
  public func endTracking(event: String = Constant.event) -> CFAbsoluteTime {
    guard let startDate = startDateMap[event] else {
      return 0
    }
    let duration = Date().timeIntervalSince(startDate)
    dbgPrint("[Perf Tracker] \(event) - duration = \(duration)")
    return duration
  }
}
