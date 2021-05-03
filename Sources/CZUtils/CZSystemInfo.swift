import Foundation

/// Helper class for system information.
@objc
public class CZSystemInfo: NSObject {
  
  // MARK: - Disk
  
  public static var availableSystemStorage: Int {
    do {
      let attributes = try FileManager.default.attributesOfFileSystem(forPath: CZFileHelper.documentDirectory)
      let freeFileSystemSizeInBytes = attributes[FileAttributeKey.systemFreeSize] as? Int
      return freeFileSystemSizeInBytes.assertIfNil ?? 0
    } catch {
      assertionFailure("Failed to retrieve available system storage. Error - \(error)")
    }
    return 0
  }
  
}
