import Foundation

/**
 Shared data between app and UITest.
 */
public class CZUITestSharedData {
  public static let shared = CZUITestSharedData()
  
  let sharedDataFileUrl = CZFileHelper.sharedGroupFolderURL(fileName: "sharedData.plist")
  
  /**
  Returns the object from the shared file if any, otherwise nil.
   */
  public func getObject<T>() -> T? {
    let res: T? = CZHTTPJsonSerializer.deserializedObject(withPathUrl: sharedDataFileUrl)
    return res
  }
  
  /**
  Saves `object` to the shared file.
   
   - Note: `object` should be JSONSerializable.
   */
  @discardableResult
  public func saveObject(_ object: Any) -> Bool {
    return CZHTTPJsonSerializer.saveJSONObject(object, to: sharedDataFileUrl)
  }
}
