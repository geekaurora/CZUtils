import XCTest
//import CZTestUtils

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
  
//  /**
//   - Warning:the value isn't released immediately after its scope.
//   */
//  func testWeakReference() {
//    var object: TestClass? = TestClass()
//    mapTable.setObject(object, forKey: Constant.key)
//
//    // Note: shouldn't assign `let actual = weakDictionary[Constant.key]`, because `acutal` will retain the value!.
//    XCTAssertTrue(
//      mapTable.object(forKey:  Constant.key) === object,
//      "Value isn't corrent. expected = \(object), actual = \(mapTable.object(forKey:  Constant.key))")
//
//    // Release `object`: expect `object` in `weakArray` is also released.
//    object = nil
//    XCTAssertTrue(mapTable.object(forKey:  Constant.key) === nil)
//  }
  
//  /**
//   The object set to NSMapTable should be weak reference.
//
//   - Warning:the value isn't released immediately after its scope.
//   */
//  func testSetObjectWithWeakReference() {
//    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Constant.timeout, testCase: self)
//
//    // Set the object for the key.
//    var object: TestClass? = TestClass()
//    mapTable.setObject(object, forKey: Constant.key)
//
//    // Note: shouldn't assign `let actual = weakDictionary[Constant.key]`, because `acutal` will retain the value!.
//    XCTAssertTrue(
//      mapTable.object(forKey:  Constant.key) === object,
//      "Value isn't corrent. expected = \(object), actual = \(mapTable.object(forKey:  Constant.key))")
//
//    // Release object.
//    object = nil
//
//    // Delay to verify the value is released.
//    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
//      XCTAssertTrue(
//        self.mapTable.object(forKey:  Constant.key) === nil, "Weak value should have been released. expected = nil.")
//      expectation.fulfill()
//    }
//
//    // Wait for expectatation.
//    waitForExpectatation()
//  }
  
}

private class TestClass: NSObject {}
