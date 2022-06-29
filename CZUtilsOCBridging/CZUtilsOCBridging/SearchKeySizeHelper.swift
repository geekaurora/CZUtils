import UIKit

/// The helper class for the search key size.
@objc
public class SearchKeySizeHelper: NSObject {
  public enum Constant {
    static let searchKeyVerticalOffset: CGFloat = 15
  }

  /// The device code of the current device.
  fileprivate static let deviceCode = getDeviceCode()

  /// Returns the search key size for the current device state.
  /// - Note If the current device isn't supported by this method, returns CGSizeZero.
  @objc
  public static func getSearchKeySize() -> CGSize {
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

  /// Returns the vertical offset of SearchKey for the current device state.
  @objc
  public static func getSearchKeyVerticalOffset() -> CGFloat {
    if deviceCodesWithZeroVerticalOffset.contains(deviceCode) {
      return 0
    }
    return Constant.searchKeyVerticalOffset
  }
}

// MARK: - Private variables / methods

extension SearchKeySizeHelper {

  /// The Sets of the grouped deviceCodes.
  fileprivate static let deviceCodeSets: [Set<String>] = [
    // iPhone 11 Pro, iPhone 12 mini, iPhone 13 mini
    Set(["iPhone12,3", "iPhone13,1", "iPhone14,4"]),
    // iPhone 12, iPhone 12 Pro, iPhone 13, iPhone 13 Pro
    Set(["iPhone13,2", "iPhone13,3", "iPhone14,5", "iPhone14,2"]),
    // iPhone 11, iPhone 11 Pro Max
    Set(["iPhone12,1", "iPhone12,5"]),
    // iPhone 12 Pro Max, iPhone 13 Pro Max
    Set(["iPhone13,4", "iPhone14,3"]),
    // iPhone 6s Plus, iPhone 8 Plus
    Set(["iPhone8,2", "iPhone10,2", "iPhone10,5"]),
  ]

  /// The grouped searchKeySizes correspond to the above deviceCode Sets.
  fileprivate static let searchKeySizes = [
    CGSize(width: 88, height: 42),
    CGSize(width: 91, height: 38),
    CGSize(width: 96, height: 45),
    CGSize(width: 100, height: 45),
    CGSize(width: 97, height: 45),
  ]

  /// The Set of deviceCodes that has zero VerticalOffset.
  fileprivate static let deviceCodesWithZeroVerticalOffset: Set<String> =
    // iPhone 6s Plus, iPhone 8 Plus
    Set(["iPhone8,2", "iPhone10,2", "iPhone10,5"])

  /// Returns the device code of the current device. e.g. "iPhone12,3".
  fileprivate static func getDeviceCode() -> String {
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
