import XCTest
@testable import CZUtils

class CZPointerArrayTests: XCTestCase {
  private var pointerArray: CZPointerArray<NSString>!
  
  override func setUp() {
    pointerArray = CZPointerArray()
  }
    
  func testAddObject() {
    let testObject = "testObject" as NSString
    pointerArray.addObject(testObject)
    let isContained = pointerArray.contains(testObject)
    XCTAssertTrue(isContained, "Array should contain testObject.")
  }
  
  func testRemoveObject() {
    let testObject = "testObject" as NSString
    pointerArray.addObject(testObject)
    var isContained = pointerArray.contains(testObject)
    XCTAssertTrue(isContained, "Array should contain testObject.")
        
    pointerArray.removeObject(testObject)
    isContained = pointerArray.contains(testObject)
    XCTAssertTrue(!isContained, "Array shouldn't contain testObject after removal.")
  }
  
  func testWeakReference() {
    var testObject: NSString? = "testObject" as NSString
    pointerArray.addObject(testObject)
    var isContained = pointerArray.contains(testObject)
    XCTAssertTrue(isContained, "Array should contain testObject.")
    
    // Release `testObject` to verify `pointerArray` only holds weak reference to it.
    testObject = nil
    isContained = self.pointerArray.contains(testObject)
    XCTAssertTrue(!isContained, "Array shouldn't contain testObject.")
  }
}
