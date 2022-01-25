import XCTest
@testable import CZUtils

final class CZFileHelperTests: XCTestCase {
  private enum MockData {
    static let dict: [String: AnyHashable] = [
      "a": "sdlfjas",
      "c": "sdlksdf",
      "b": "239823sd",
      "d": 189298723,
    ]
  }
  
  private enum Constant {
    static let timeOut: TimeInterval = 30
  }
  static let testFileUrl = URL(fileURLWithPath: CZFileHelper.documentDirectory + "testFile.plist")
  
  override class func setUp() {
    removeTestFile()
  }
  
  override class func tearDown() {
    removeTestFile()
  }
  
  // MARK: - Basics
    
  func testFileExists() {
   Self.writeTestFile()
    let isExisting = CZFileHelper.fileExists(url: Self.testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(Self.testFileUrl).")
  }
  
  func testFileNotExists() {
   Self.writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: Self.testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(Self.testFileUrl).")
    
    CZFileHelper.removeFile(Self.testFileUrl)
    isExisting = CZFileHelper.fileExists(url: Self.testFileUrl)
    XCTAssertTrue(!isExisting, "File shouldn't exist on disk - \(Self.testFileUrl).")
  }
  
  func testRemoveFile() {
   Self.writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: Self.testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(Self.testFileUrl).")
    
    CZFileHelper.removeFile(Self.testFileUrl)
    isExisting = CZFileHelper.fileExists(url: Self.testFileUrl)
    XCTAssertTrue(!isExisting, "File shouldn't exist on disk - \(Self.testFileUrl).")
  }
  
  // MARK: - Directory

  func testRemoveDirectory() {
   Self.writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: Self.testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(Self.testFileUrl).")
    
    CZFileHelper.removeFile(Self.testFileUrl)
    isExisting = CZFileHelper.fileExists(url: Self.testFileUrl)
    XCTAssertTrue(!isExisting, "File shouldn't exist on disk - \(Self.testFileUrl).")
  }
  
}

// MARK: - Helper methods

private extension CZFileHelperTests {
  static func writeTestFile() {
    let mockData = CZHTTPJsonSerializer.jsonData(with: MockData.dict)!
    do {
      try mockData.write(to: testFileUrl)
    } catch {
      assertionFailure("Failed to write file \(testFileUrl). error - \(error.localizedDescription)")
    }
  }
  
  static func removeTestFile() {
    CZFileHelper.removeFile(testFileUrl)
  }
}
