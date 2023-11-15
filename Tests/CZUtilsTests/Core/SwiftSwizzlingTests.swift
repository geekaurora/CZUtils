import XCTest

@testable import CZUtils

private let testString = "testSwizzling"

extension CZSystemInfo {
  @_dynamicReplacement(for: getDeviceType())
  public static func getDeviceTypeSwizzled() -> String {
    return testString
  }
}

class SwiftSwizzlingTests: XCTestCase {
  func testSwizzling() {
    XCTAssertEqual(CZSystemInfo.getDeviceType(), testString)
  }
}
