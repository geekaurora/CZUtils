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
  
  private(set) lazy var folder: String = {
    let folder = CZFileHelper.documentDirectory + "TestFolder/"
    CZFileHelper.createDirectoryIfNeeded(at: folder)
    return folder
  }()
  
  lazy var testFileUrl = URL(fileURLWithPath: folder + "testFile.plist")
  
  override func setUp() {
    removeTestFile()
  }
  
  override func tearDown() {
    removeTestFile()
  }
  
  // MARK: - Basics
    
  func testFileExists() {
   writeTestFile()
    let isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(testFileUrl).")
  }
  
  func testFileNotExists() {
   writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(testFileUrl).")
    
    CZFileHelper.removeFile(testFileUrl)
    isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(!isExisting, "File shouldn't exist on disk - \(testFileUrl).")
  }
  
  func testRemoveFile() {
   writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(testFileUrl).")
    
    CZFileHelper.removeFile(testFileUrl)
    isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(!isExisting, "File shouldn't exist on disk - \(testFileUrl).")
  }
  
  // MARK: - Directory

  func testRemoveDirectory() {
   writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(isExisting, "File should exist on disk - \(testFileUrl).")
    
    CZFileHelper.removeFile(testFileUrl)
    isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(!isExisting, "File shouldn't exist on disk - \(testFileUrl).")
  }
  
}

// MARK: - Helper methods

private extension CZFileHelperTests {
  func writeTestFile() {
    let mockData = CZHTTPJsonSerializer.jsonData(with: MockData.dict)!
    do {
      try mockData.write(to: testFileUrl)
    } catch {
      assertionFailure("Failed to write file \(testFileUrl). error - \(error.localizedDescription)")
    }
  }
  
  func removeTestFile() {
    CZFileHelper.removeFile(testFileUrl)
  }
}
