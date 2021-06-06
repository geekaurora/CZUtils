import XCTest
@testable import CZUtils

class WeakWrapperTests: XCTestCase {
  
  func testWeakReference() {
    var object: TestClass? = TestClass()
    let weakWrapper = WeakWrapper(object!)
    XCTAssertTrue(weakWrapper.element === object, "Value isn't corrent. expected = \(object), actual = \(weakWrapper.element)")
  
    // Release `object`: expect `object` is also released.
    object = nil
    XCTAssertTrue(weakWrapper.element === nil)
  }
}

private class TestClass {}
