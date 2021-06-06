import XCTest
import CZTestUtils

@testable import CZUtils

class WeakDictionaryTests: XCTestCase {
  private enum Constant {
    static let key = "foo"
    static let timeout: TimeInterval = 30
  }
  var weakDictionary: WeakDictionary<AnyHashable, AnyObject>!

  override func setUp() {
    weakDictionary = WeakDictionary<AnyHashable, AnyObject>()
  }
  
  func testSetObject() {
    let object = TestClass()
    weakDictionary[Constant.key] = object
    
    let actual = weakDictionary[Constant.key]
    XCTAssertTrue(actual === object, "Value isn't corrent. expected = \(object), actual = \(actual)")
  }
  
  func testWeakReference() {
    var object: TestClass? = TestClass()
    weakDictionary[Constant.key] = object
    
    // Note: shouldn't assign `let actual = weakDictionary[Constant.key]`, because `acutal` will retain the value!.
    XCTAssertTrue(
      weakDictionary[Constant.key] === object,
      "Value isn't corrent. expected = \(object), actual = \(weakDictionary[Constant.key])")
  
    // Release `object`: expect `object` in `weakArray` is also released.
    object = nil
    XCTAssertEqual(weakDictionary.count, 0)
  }
  
  /**
   The object being set should be weak reference.
   */
  func testSetObjectWithWeakReference() {
    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Constant.timeout, testCase: self)
    
    // Set the object for the key.
    var object: TestClass? = TestClass()
    weakDictionary[Constant.key] = object
    
    // Note: shouldn't assign `let actual = weakDictionary[Constant.key]`, because `acutal` will retain the value!.
    XCTAssertTrue(weakDictionary[Constant.key] === object, "Value isn't corrent. expected = \(object), actual = \(weakDictionary[Constant.key])")

    // Delay to verify the value is released.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let actual = self.weakDictionary[Constant.key]
      print("actual = \(actual), object = \(object), weakDictionary.count = \(self.weakDictionary.count)")
      XCTAssertTrue(actual === nil, "Value isn't corrent. expected = nil, actual = \(actual)")
      expectation.fulfill()
    }
    
    object = nil
    
    // Wait for expectatation.
    waitForExpectatation()
  }
}

private class TestClass {}
