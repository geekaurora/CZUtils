import XCTest
@testable import CZUtils

class TestThreadSafeWeakArray: XCTestCase {
  static let total = 30000
  static let queueLable = "com.czutils.tests"
  private var weakArray: ThreadSafeWeakArray<TestClass>!
  
  override func setUp() {
    weakArray = ThreadSafeWeakArray<TestClass>()
  }
  
  func testAppend() {
    let object = TestClass()
    weakArray.append(object)
    XCTAssert(weakArray.contains(object))
  }

  func testRemove() {
    let object = TestClass()
    weakArray.append(object)
    XCTAssert(weakArray.contains(object))

    weakArray.remove(object)
    XCTAssert(!weakArray.contains(object))
  }
  
  func testWeakReference() {    
    // Append `object` to `weakArray`.
    var object: TestClass? = TestClass()
    weakArray.append(object!)
    XCTAssert(weakArray.contains(object!))

    // Release `object`: expect `object` in `weakArray` is also released.
    object = nil
    XCTAssertEqual(weakArray.count, 0)
  }
  
  func testMultiThread() {
    let dispatchGroup = DispatchGroup()
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    
    // Test adding objects on multiple threads.
    let items = (0..<Self.total).map { _ in TestClass() }
    items.forEach { item in
      dispatchGroup.enter()
      queue.async {
        self.weakArray.append(item)
        dispatchGroup.leave()
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` of weakArray with the expected value.
    XCTAssertEqual(weakArray.count, Self.total)
  }
}

private class TestClass {}

