import XCTest
@testable import CZUtils

class ThreadSafeArrayTests: XCTestCase {
  static let total = 30000
  static let queueLable = "com.czutils.tests"
  private var testArray: ThreadSafeArray<TestClass>!
  
  override func setUp() {
    testArray = ThreadSafeArray<TestClass>()
  }
  
  func testAppend() {
    let object = TestClass()
    testArray.append(object)
    XCTAssert(testArray.contains(object))
  }

  func testRemove() {
    let object = TestClass()
    testArray.append(object)
    XCTAssert(testArray.contains(object))

    testArray.remove(object)
    XCTAssert(!testArray.contains(object))
  }
  
  func testMultiThread() {
    let dispatchGroup = DispatchGroup()
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    
    // Test adding objects on multiple threads.
    let items = (0..<Self.total).map { _ in TestClass() }
    items.forEach { item in
      dispatchGroup.enter()
      queue.async {
        self.testArray.append(item)
        dispatchGroup.leave()
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` of testArray with the expected value.
    XCTAssertEqual(testArray.count, Self.total)
  }
}

private class TestClass {}
