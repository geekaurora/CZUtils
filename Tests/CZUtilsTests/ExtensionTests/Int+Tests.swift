import XCTest
@testable import CZUtils

class IntExtensionTests: XCTestCase {
  
  func testSizeString() {
    var size = 1000
    var actual = size.sizeString
    var expected = "\(size)"
    XCTAssert(actual == expected, "Incorrect format! actual = \(actual), expected = \(expected)")
    
    size = 3 * 1024 + 2
    actual = size.sizeString
    expected = "3 K"
    XCTAssert(actual == expected, "Incorrect format! actual = \(actual), expected = \(expected)")
    
    size = 5 * 1024 * 1024 + 3 * 1024 + 2
    actual = size.sizeString
    expected = "5 M"
    XCTAssert(actual == expected, "Incorrect format! actual = \(actual), expected = \(expected)")
    
    size = 7 * 1024 * 1024 * 1024 + 3 * 1024
    actual = size.sizeString
    expected = "7 G"
    XCTAssert(actual == expected, "Incorrect format! actual = \(actual), expected = \(expected)")
  }
}
