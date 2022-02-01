import os.signpost

/**
 Helper of os_signpost() method.
 
 - Note: Should select signpost profiling template when starting instrument.
 
 ### Usage
 ```
 CZSignpostHelper.shared.start()
 CZSignpostHelper.shared.end()
 ```
 */
public class CZSignpostHelper {
  
  public static let shared = CZSignpostHelper()
  
  public enum Constant {
    public static let subsystem = "com.cz.app"
    public static let category = "CZSignpostEvents"
    public static let eventName: StaticString = "CZLoadFileEvent"
    public static let subeventName: StaticString = "CZLoadFileEvent"
  }
  
  private let log: OSLog
  private let signpostID: OSSignpostID
  
  public init() {
    log = OSLog(subsystem: Constant.subsystem, category: Constant.category)
    signpostID = OSSignpostID(log: log)
  }
  
  // TODO: Add dynamic support for `eventName` - Xcode compiler requires eventName to be static string.
  
  /// Start the event with params.
  ///
  /// - Note: `eventName` / `subeventName` should be `StaticString` - immutable and decided during compile time.
  public func start(eventName: StaticString = Constant.eventName,
                    subeventName: StaticString = Constant.subeventName) {
    os_signpost(
      .begin,
      log: log,
      name: eventName,
      signpostID: signpostID,
      subeventName)
  }
  
  public func end(eventName: StaticString = Constant.eventName,
                  subeventName: StaticString = Constant.subeventName)  {
    os_signpost(
      .end,
      log: log,
      name: eventName,
      signpostID: signpostID,
      subeventName)
  }
  
}
