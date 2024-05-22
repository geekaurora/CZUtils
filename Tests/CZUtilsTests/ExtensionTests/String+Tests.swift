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

  // MARK: - Test - extractEnclosedString()

  func testExtractEnclosedString() {
    let startChar: Character = "["
    let endChar: Character = "]"

    // Test "[123]".
    var testString = "[123]"
    var actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    var expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "123")

    // Test "[]".
    testString = "[]"
    actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "")

    // Test "123".
    testString = "123"
    actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "123")

    // Test "".
    testString = ""
    actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "")
  }
}
