import XCTest
@testable import CZUtils

class CZPointerArrayTests: XCTestCase {
  private var pointerArray: CZPointerArray<NSString>!
  
  override func setUp() {
    pointerArray = CZPointerArray()
  }
    
  func testAddObject() {
    let testView = "test" as NSString
    pointerArray.addObject(nil)
    pointerArray.addObject(testView)
    pointerArray.addObject(nil)
    print("pointerArray: \(pointerArray)")
    
    pointerArray.removeObject(testView)
    print("pointerArray: \(pointerArray)")
    
  }
  
  func testWeakReference() {
    // async
  }
}
