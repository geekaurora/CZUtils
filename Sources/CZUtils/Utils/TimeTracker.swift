import Foundation

/**
 Tracker that tracks elapsed time.

 ### Usage

 ```
   let timeTracker = TimeTracker()
   timeTracker.start()
   ...
   let time = timeTracker.endAndCaculateTime()
 ```
 */
public class TimeTracker {
  private var startTime: CFAbsoluteTime?

  public init() {}
  
  /// Starts the tracking.
  public func start() {
    self.startTime = CFAbsoluteTimeGetCurrent()
  }

  /// Returns time interval between now and start.
  public func endAndCaculateTime() -> CFAbsoluteTime {
    guard let startTime = startTime.assertIfNil else {
      return 0
    }
    return CFAbsoluteTimeGetCurrent() - startTime
  }
}
