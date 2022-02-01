import Foundation

/**
 Shared data between app and UITest.
 
 - In UITest : Set the shared data via XCUIApplication.launchEnvironment before launching the app.
 - In app     : Read the shared data via ProcessInfo.
 */
public class CZUITestSharedData {
  public static let shared = CZUITestSharedData()
  
  public static let key = "kUITestSharedData"
  
  private var savedObjectString: String?
  
  /**
  For app: returns the object from the shared file if any, otherwise nil.
   
   - Note: It reads from Process info of app.
   */
  public func getObject<T>() -> T? {
    // Read data from ProcessInfo of the current process .
    guard let personInfo = ProcessInfo.processInfo.environment[Self.key],
          let data = personInfo.data(using: .utf8).assertIfNil else {
            dbgPrintWithFunc(self, type: .warning, "ProcessInfo.processInfo.environment[\(Self.key)] is nil!")
            return nil
          }
    return CZHTTPJsonSerializer.deserializedObject(with: data)
  }
  
  /**
  For UITest: set `launchEnvironment` for XCUIApplication.
   
   - Note: Should use `CZUITestSharedData.key` as the key of launchEnvironment.
   */
  public var launchEnvironmentValueForUITest: String? {
    return savedObjectString.assertIfNil
  }
  
  /**
  Saves `object` to the shared file.
   
   - Note: `object` should be JSONSerializable and should set `launchEnvironmentValueForUITest` for UITest.launchEnvironment.
   */
  @discardableResult
  public func saveObject(_ object: Any) -> Bool {
    guard let data = CZHTTPJsonSerializer.jsonData(with: object).assertIfNil else {
      return false
    }
    savedObjectString =  String(data: data, encoding: .utf8)
    return true
  }
}
