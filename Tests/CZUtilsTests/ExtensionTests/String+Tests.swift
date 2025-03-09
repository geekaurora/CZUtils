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

  // MARK: - Test - cz_extractEnclosedString()

  func testExtractEnclosedString() {
    let startChar: Character = "["
    let endChar: Character = "]"

    // Test "[123]".
    var testString = "[123]"
    var actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    var expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "123")

    // Test "[]".
    testString = "[]"
    actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "")

    /** Test same startChar / endChar: "\"". */

    // Multiple chars.

    testString = "\"123\""
    actual = testString.cz_extractEnclosedString(
      startChar: "\"", endChar: "\"", shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    testString = "\"123\""
    actual = testString.cz_extractEnclosedString(
      startChar: "\"", endChar: "\"", shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "123")

    // Single char.
    testString = "\""
    actual = testString.cz_extractEnclosedString(
      startChar: "\"", endChar: "\"", shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    testString = "\""
    actual = testString.cz_extractEnclosedString(
      startChar: "\"", endChar: "\"", shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, expected)

    // Test "123".
    testString = "123"
    actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "123")

    // Test "".
    testString = ""
    actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.cz_extractEnclosedString(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "")
  }

  func testExtractEnclosedString_experimental() {
    let startChar: Character = "["
    let endChar: Character = "]"

    // Test "[123]".
    var testString = "[123]"
    var actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    var expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "123")

    // Test "[]".
    testString = "[]"
    actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "")

    // Test "123".
    testString = "123"
    actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "123")

    // Test "".
    testString = ""
    actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: true)
    expected = testString
    XCTAssertEqual(actual, expected)

    actual = testString.extractEnclosedString_experiment(
      startChar: startChar, endChar: endChar, shouldIncludeBoundaries: false)
    expected = testString
    XCTAssertEqual(actual, "")
  }
}

// MARK: - Experiment

extension String {
  /// Extracts the enclosed string between `startChar` and `endChar`.
  func extractEnclosedString_experiment(startChar: Character,
                                        endChar: Character,
                                        shouldIncludeBoundaries: Bool = true) -> String {
    var result = ""
    var foundStartChar = false
    var foundEndChar = false

    for char in self {
      if foundStartChar {

        if char == endChar {
          foundEndChar = true

          if shouldIncludeBoundaries {
            result += String(char)
          }
          break
        }

        result += String(char)
      }

      if char == startChar {
        foundStartChar = true
        if shouldIncludeBoundaries {
          result += String(char)
        }
      }
    }
    return (foundStartChar && foundEndChar) ? result : self
  }
}
