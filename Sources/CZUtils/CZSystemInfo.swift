import Foundation
import UIKit

/// Helper class for system information.
@objc
public class CZSystemInfo: NSObject {
  
  // MARK: - CPU
  
  public static func getDeviceType() -> String {
    return UIDevice().type
  }
  
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

// MARK: - Device Type

public extension UIDevice {
  var type: String {
    var systemInfo = utsname()
    uname(&systemInfo)
    
    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let identifier = machineMirror.children.reduce("") { identifier, element in
      guard let value = element.value as? Int8, value != 0 else { return identifier }
      return identifier + String(UnicodeScalar(UInt8(value)))
    }
    
    switch identifier {
    case "iPod5,1":                                 return "iPod Touch 5"
    case "iPod7,1":                                 return "iPod Touch 6"
    case "iPhone3,1", "iPhone3,2", "iPhone3,3":     return "iPhone 4"
    case "iPhone4,1":                               return "iPhone 4s"
    case "iPhone5,1", "iPhone5,2":                  return "iPhone 5"
    case "iPhone5,3", "iPhone5,4":                  return "iPhone 5c"
    case "iPhone6,1", "iPhone6,2":                  return "iPhone 5s"
    case "iPhone7,2":                               return "iPhone 6"
    case "iPhone7,1":                               return "iPhone 6 Plus"
    case "iPhone8,1":                               return "iPhone 6s"
    case "iPhone8,2":                               return "iPhone 6s Plus"
    case "iPhone9,1", "iPhone9,3":                  return "iPhone 7"
    case "iPhone9,2", "iPhone9,4":                  return "iPhone 7 Plus"
    case "iPhone8,4":                               return "iPhone SE"
      
      
    case "iPhone10,1", "iPhone10,4":                return "iPhone8"
    case "iPhone10,2", "iPhone10,5":                return "iPhone8Plus"
    case "iPhone10,3", "iPhone10,6":                return "iPhoneX"
    case "iPhone11,2":                              return "iPhoneXS"
    case "iPhone11,4", "iPhone11,6":                return "iPhoneXSMax"
    case "iPhone11,8":                              return "iPhoneXR"
    case "iPhone12,1":                              return "iPhone11"
    case "iPhone12,3":                              return "iPhone11Pro"
    case "iPhone12,5":                              return "iPhone11ProMax"
      
    case "iPad2,1", "iPad2,2", "iPad2,3", "iPad2,4":return "iPad 2"
    case "iPad3,1", "iPad3,2", "iPad3,3":           return "iPad 3"
    case "iPad3,4", "iPad3,5", "iPad3,6":           return "iPad 4"
    case "iPad4,1", "iPad4,2", "iPad4,3":           return "iPad Air"
    case "iPad5,3", "iPad5,4":                      return "iPad Air 2"
    case "iPad2,5", "iPad2,6", "iPad2,7":           return "iPad Mini"
    case "iPad4,4", "iPad4,5", "iPad4,6":           return "iPad Mini 2"
    case "iPad4,7", "iPad4,8", "iPad4,9":           return "iPad Mini 3"
    case "iPad5,1", "iPad5,2":                      return "iPad Mini 4"
    case "iPad6,3", "iPad6,4", "iPad6,7", "iPad6,8":return "iPad Pro"
    case "AppleTV5,3":                              return "Apple TV"
    case "i386", "x86_64":                          return "Simulator"
    default:                                        return identifier
    }
  }
  
}
