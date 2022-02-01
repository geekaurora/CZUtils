import os.signpost

/**
 Helper of os_signpost() method.
 
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
    public static let category = "RecordLoading"
    public static let eventName = "CZ Read File"
    public static let eventDescription = "File2"
  }
  
  private let log: OSLog
  private let signpostID: OSSignpostID
  
  public init() {
    log = OSLog(subsystem: Constant.subsystem, category: Constant.category)
    signpostID = OSSignpostID(log: log)
  }
  
  public func start(eventName: String = Constant.eventName,
                    eventDescription: String = Constant.eventDescription) {
    os_signpost(
      .begin,
      log: log,
      name: "CZ Read File",
      signpostID: signpostID,
      "File2"
    )
  }
  
  public func end(eventName: String = Constant.eventName,
                  eventDescription: String = Constant.eventDescription)  {
    os_signpost(
      .end,
      log: log,
      name: "CZ Read File",
      signpostID: signpostID,
      "File2"
    )
  }
  
}
