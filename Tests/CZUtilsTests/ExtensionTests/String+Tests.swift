import XCTest
@testable import CZUtils

class StringExtensionTests: XCTestCase {
  func testFileType() {
    let string = "file:///user/some/path/file.mp3"
    let actual = string.fileType()
    let expected = "mp3"
    XCTAssert(actual == expected, "fileType() failed! actual = \(actual), expected = \(expected)")
  }
  
  func testFileTypeIncludingDot() {
    let string = "file:///user/some/path/file.mp3"
    let actual = string.fileType(includingDot: true)
    let expected = ".mp3"
    XCTAssert(actual == expected, "fileType() failed! actual = \(actual), expected = \(expected)")
  }
  
  func testFileTypeWithIllegalString1() {
    let string = "file:///user/some/path/file.m/p3"
    let actual = string.fileType()
    let expected = ""
    XCTAssert(actual == expected, "fileType() failed! actual = \(actual), expected = \(expected)")
  }
  
  func testFileTypeWithIllegalString2() {
    let string = "file:///user/some/path/file.m\\p3"
    let actual = string.fileType()
    let expected = ""
    XCTAssert(actual == expected, "fileType() failed! actual = \(actual), expected = \(expected)")
  }
  
}
