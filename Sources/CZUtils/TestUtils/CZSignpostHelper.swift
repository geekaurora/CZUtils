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
  }
  
  private let log: OSLog
  private let signpostID: OSSignpostID
  
  public init() {
    log = OSLog(subsystem: Constant.subsystem, category: Constant.category)
    signpostID = OSSignpostID(log: log)
  }
  
  // TODO: Add dynamic support for `eventName` - Xcode compiler requires eventName to be static string.
  public func start() {
    os_signpost(
      .begin,
      log: log,
      name: "CZLoadFileEvent",
      signpostID: signpostID,
      "CZLoadFileSubEvent"
    )
  }
  
  public func end()  {
    os_signpost(
      .end,
      log: log,
      name: "CZLoadFileEvent",
      signpostID: signpostID,
      "CZLoadFileSubEvent"
    )
  }
  
}
