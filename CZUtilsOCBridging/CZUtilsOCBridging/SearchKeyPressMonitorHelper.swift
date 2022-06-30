import UIKit

//extension SearchKeyPressMonitorHelper {
//  static func GMOIsPortrait() -> Bool{
//    return UIApplication.shared.statusBarOrientation.isPortrait
//  }
//
//  static func GMOHasRTLLayout(_ view: UIView?) -> Bool{
//    return false
//  }
//}


/// The helper class for the SearchKeyPressMonitor.
@objc
public class SearchKeyPressMonitorHelper: NSObject {
  public enum Constant {
    static let searchKeyPadding: CGFloat = 5
    static let searchKeyVerticalOffset: CGFloat = 15
  }

  /// The device code of the current device.
  fileprivate static let deviceCode = getCurrentDeviceCode()

  /// The index of `deviceCodeSets` whose deviceCodeSet contains the current device.
  fileprivate static var deviceCodeSetIndex: Int?

  /// Returns whether the `event` is search key press-down event.
  @objc(isSearchKeyPressedDownWithEvent:)
  public static func isSearchKeyPressedDown(with event: UIEvent) -> Bool {
    guard let allTouches = event.allTouches,
          let touch = allTouches.first,
          let keyboardWindow = touch.window,
          let keyboardView = touch.view else {
            return false
          }

    let isKeyboardRTLLayout = keyboardView.traitCollection.layoutDirection == .rightToLeft
    if allTouches.count != 1 || isKeyboardRTLLayout || !Self.isDeviceStateSupported() {
      return false
    }

    // Check whether the event is keyboard touch and in UITouchPhaseBegan phase.
    if touch.phase != .began ||
        NSStringFromClass(type(of: keyboardWindow)) != "UIRemoteKeyboardWindow" ||
        NSStringFromClass(type(of: keyboardView)) != "UIKeyboardLayoutStar" {
      return false
    }

    // Start checking whether the touch point is inside the search key rectangle.
    let touchPoint = touch.location(in: keyboardView)
    let keyboardViewSize = keyboardView.frame.size

    // The size of the search key rectangle.
    let searchKeySize = Self.getSearchKeySize()
    if searchKeySize.equalTo(.zero) {
      // If |searchKeySize| equals CGSizeZero, it means the current device isn't supported checking
      // search key press-down event.
      return false
    }

    // Search key padding to the keyboard view.
    let padding = Constant.searchKeyPadding
    // Vertical offset for large devices: the microphone icon has a separate row.
    // On small devices the microphone icon is inside the keyboard.
    let verticalOffset = Self.getSearchKeyVerticalOffset()
    // The rectangle of the search key: right bottom corner of the keyboard view.
    let searchKeyRect = CGRect(
      x: keyboardViewSize.width - searchKeySize.width - padding,
      y: keyboardViewSize.height - searchKeySize.height - padding - verticalOffset,
      width: searchKeySize.width, height: searchKeySize.height)

    // Return whether the touch point is inside the search key rectangle.
    return searchKeyRect.contains(touchPoint)
  }
}

// MARK: - Private variables / methods

extension SearchKeyPressMonitorHelper {

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

  fileprivate static func isDeviceStateSupported() -> Bool {
    return UIApplication.shared.statusBarOrientation.isPortrait
  }

  /// Returns the search key size for the current device state.
  /// - Note If the current device isn't supported by this method, returns CGSizeZero.
  fileprivate static func getSearchKeySize() -> CGSize {
    if let deviceCodeSetIndex = Self.deviceCodeSetIndex {
      if deviceCodeSetIndex == -1 {
        return .zero
      } else {
        return searchKeySizes[deviceCodeSetIndex]
      }
    }

    for (i, deviceCodeSet) in deviceCodeSets.enumerated() where deviceCodeSet.contains(deviceCode) {
      if i < searchKeySizes.count {
        // Cache the index of the deviceCode.
        Self.deviceCodeSetIndex = i
        return searchKeySizes[i]
      } else {
        assertionFailure("`deviceCodeSets` size should equal `searchKeySizes` size.")
        break
      }
    }
    Self.deviceCodeSetIndex = -1
    return .zero
  }

  /// Returns the vertical offset of SearchKey for the current device state.
  fileprivate static func getSearchKeyVerticalOffset() -> CGFloat {
    if deviceCodesWithZeroVerticalOffset.contains(deviceCode) {
      return 0
    }
    return Constant.searchKeyVerticalOffset
  }

  /// Returns the device code of the current device. e.g. "iPhone12,3".
  fileprivate static func getCurrentDeviceCode() -> String {
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
