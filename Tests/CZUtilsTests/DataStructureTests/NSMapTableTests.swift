import XCTest
import CZTestUtils

@testable import CZUtils

class NSMapTableTests: XCTestCase {
  private enum Constant {
    static let key = "foo" as NSString
    static let timeout: TimeInterval = 30
  }
  var mapTable: NSMapTable<AnyObject, AnyObject>!

  override func setUp() {
    mapTable = NSMapTable(keyOptions: .strongMemory, valueOptions: .weakMemory)
  }
  
  func testSetObject() {
    let object = TestClass()
    mapTable.setObject(object, forKey: Constant.key)
    
    let actual = mapTable.object(forKey:  Constant.key)
    XCTAssertTrue(actual === object, "Value isn't corrent. expected = \(object), actual = \(actual)")
  }
  
  /**
   The object set to NSMapTable should be weak reference.
   
   - Warning:the value isn't released immediately after its scope.
   */
//  func testSetObjectWithWeakReference() {
//    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Constant.timeout, testCase: self)
//      
//    // Set the object for the key.
//    let object = TestClass()
//    mapTable.setObject(object, forKey: Constant.key)
//    
//    // Verify the value is set correctly.
//    let actual = mapTable.object(forKey:  Constant.key)
//    XCTAssertTrue(actual === object, "Value isn't corrent. expected = \(object), actual = \(actual)")
//    
//    // Delay to verify the value is released.
//    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
//      let expected: AnyObject? = nil
//      let actual = self.mapTable.object(forKey:  Constant.key)
//      XCTAssertTrue(actual === expected, "Value isn't corrent. expected = \(expected), actual = \(actual)")
//      expectation.fulfill()
//    }
//    
//    // Wait for expectatation.
//    waitForExpectatation()
//  }
}

private class TestClass: NSObject {}
