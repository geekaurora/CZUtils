import Foundation
import UIKit

@objc
public class SearchKeySizeHelper: NSObject {
  static let deviceCodeSets: [Set<String>] = [
    // @"iPhone 11 Pro", @"iPhone 12 mini", @"iPhone 13 mini"
    Set(["iPhone12,3", "iPhone13,1", "iPhone14,4"]),
  ]

  static let searchKeySizes = [
    CGSize(width: 88, height: 42),
  ]

  @objc
  public static func searchKeySize(with deviceCode:String) -> CGSize {
    for (i, deviceCodeSet) in deviceCodeSets.enumerated() where deviceCodeSet.contains(deviceCode) {
      if i < searchKeySizes.count {
        return searchKeySizes[i]
      } else {
        assertionFailure("`deviceCodeSets` size should equal `searchKeySizes` size.")
        return .zero
      }
    }
    return .zero
  }

  /// Returns the device code of the current device. e.g. "iPhone12,3".
  @objc
  public static var deviceCode: String {
    var systemInfo = utsname()
    uname(&systemInfo)

    let machineMirror = Mirror(reflecting: systemInfo.machine)
    let deviceCode = machineMirror.children.reduce("") { deviceCode, element in
      guard let value = element.value as? Int8, value != 0 else {
        return deviceCode
      }
      return deviceCode + String(UnicodeScalar(UInt8(value)))
    }

 #if DEBUG
    // Simulator.
    if ["i386", "x86_64", "arm64"].contains(deviceCode) {
      return ProcessInfo().environment["SIMULATOR_MODEL_IDENTIFIER"] ?? "Simulator"
    }
#endif
    return deviceCode
  }
}
