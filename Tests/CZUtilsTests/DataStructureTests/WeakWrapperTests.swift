import XCTest
@testable import CZUtils

class WeakWrapperTests: XCTestCase {
  private var weakArray: ThreadSafeWeakArray<TestClass>!
  
  override func setUp() {
    weakArray = ThreadSafeWeakArray<TestClass>()
  }
  
  func testWeakReference() {
    // Append `object` to `weakArray`.
    var object: TestClass? = TestClass()
    weakArray.append(object!)
    XCTAssert(weakArray.contains(object!))
    XCTAssertEqual(weakArray.count, 1)
    
    // Release `object`: expect `object` in `weakArray` is also released.
    object = nil
    XCTAssertEqual(weakArray.count, 0)
  }
  
  func testWeakReference2() {
    var object: TestClass? = TestClass()
    let weakWrapper = WeakWrapper(object!)
    
    let actual = weakWrapper.element
    XCTAssertTrue(actual === object, "Value isn't corrent. expected = \(object), actual = \(actual)")
  
    // Release `object`: expect `object` is also released.
    object = nil
    weakWrapper.element = nil
    XCTAssertTrue(weakWrapper.element === nil)
  }
}

private class TestClass {}
