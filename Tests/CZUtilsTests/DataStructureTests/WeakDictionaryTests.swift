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
  
  /**
   The object being set should be weak reference.
   */
  func testSetObjectWithWeakReference() {
    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Constant.timeout, testCase: self)
      
    // Set the object for the key.
    var object: TestClass? = TestClass()
    weakDictionary[Constant.key] = object
    
    let actual = weakDictionary[Constant.key]
    XCTAssertTrue(actual === object, "Value isn't corrent. expected = \(object), actual = \(actual)")

    // Delay to verify the value is released.
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      let expected: AnyObject? = nil
      let actual = self.weakDictionary[Constant.key]
      XCTAssertTrue(actual === expected, "Value isn't corrent. expected = \(expected), actual = \(actual)")
      expectation.fulfill()
    }
    
    object = nil
    
    // Wait for expectatation.
    waitForExpectatation()
  }
}

private class TestClass: NSObject {}
