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
  
  private lazy var testFolderPath: String = {
    let testFolderPath = CZFileHelper.documentDirectory + "TestFolder/"
    CZFileHelper.createDirectoryIfNeeded(at: testFolderPath)
    return testFolderPath
  }()
  
  private lazy var testFileUrl = URL(fileURLWithPath: testFolderPath + "testFile.plist")
  
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
  
  func testCreateDirectory() {
    // Call removeDirectory() without createDirectoryAfterDeletion.
    CZFileHelper.removeDirectory(path: testFolderPath)
    
    var isExisting = CZFileHelper.fileExists(url: URL(fileURLWithPath: testFolderPath))
    XCTAssertTrue(!isExisting, "After removeDirectory() - \(testFolderPath), directory shouldn't exist on disk.")
    
    // Call createDirectoryIfNeeded() to create directory.
    CZFileHelper.createDirectoryIfNeeded(at: testFolderPath)
    isExisting = CZFileHelper.fileExists(url: URL(fileURLWithPath: testFolderPath))
    XCTAssertTrue(isExisting, "After createDirectoryIfNeeded() - \(testFolderPath), directory should exist on disk.")
  }
  
  func testRemoveDirectoryWithoutCreateDirectoryAfterDeletion() {
    writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(CZFileHelper.fileExists(url: testFileUrl), "File should exist on disk - \(testFileUrl).")
    
    // Call removeDirectory() without createDirectoryAfterDeletion.
    CZFileHelper.removeDirectory(path: testFolderPath)
    isExisting = CZFileHelper.fileExists(url: URL(fileURLWithPath: testFolderPath))
    XCTAssertTrue(!isExisting, "After removeDirectory() - \(testFolderPath), directory shouldn't exist on disk.")
    
    isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(!isExisting, "After removeDirectory() - \(testFolderPath), file shouldn't exist on disk - \(testFileUrl).")
  }
  
  func testRemoveDirectoryWithCreateDirectoryAfterDeletion() {
    writeTestFile()
    var isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(CZFileHelper.fileExists(url: testFileUrl), "File should exist on disk - \(testFileUrl).")
    
    // Call removeDirectory() with createDirectoryAfterDeletion.
    CZFileHelper.removeDirectory(path: testFolderPath, createDirectoryAfterDeletion: true)
    isExisting = CZFileHelper.fileExists(url: URL(fileURLWithPath: testFolderPath))
    XCTAssertTrue(isExisting, "After removeDirectory() - \(testFolderPath), directory should exist on disk - createDirectoryAfterDeletion = true.")
    
    isExisting = CZFileHelper.fileExists(url: testFileUrl)
    XCTAssertTrue(!isExisting, "After removeDirectory() - \(testFolderPath), file shouldn't exist on disk - \(testFileUrl).")
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
