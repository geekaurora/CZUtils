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
  
  public static func getURLSessionInfo() {
    // The settings can be updated.    
    // diskCapacity: Simulator = 10M, device = 10M (used = 12M)
    
    dbgPrint("URLCache.shared.currentDiskUsage = \(URLCache.shared.currentDiskUsage.sizeString), URLCache.shared.diskCapacity = \(URLCache.shared.diskCapacity.sizeString)")
    
    // memoryCapacity: 512K
    // dbgPrint("URLCache.shared.currentMemoryUsage = \(URLCache.shared.currentMemoryUsage), URLCache.shared.memoryCapacity = \(URLCache.shared.memoryCapacity)")
  }
  
}
