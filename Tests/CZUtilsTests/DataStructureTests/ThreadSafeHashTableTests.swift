import XCTest
@testable import CZUtils

class ThreadSafeHashTableTests: XCTestCase {
  static let total = CZUnitTestConstants.concurrentCount
  static let queueLable = "com.czutils.tests"

  let lock = SimpleThreadLock()
  var threadSafeHashTable: ThreadSafeHashTable<AnyObject>!
  
  override func setUp() {
    threadSafeHashTable = ThreadSafeHashTable<AnyObject>()
  }
  
  func testAdd() {
    let object = TestClass()
    threadSafeHashTable.add(object)
    XCTAssert(threadSafeHashTable.contains(object))
  }

  func testRemove() {
    let object = TestClass()
    threadSafeHashTable.add(object)
    XCTAssert(threadSafeHashTable.contains(object))

    threadSafeHashTable.remove(object)
    XCTAssert(!threadSafeHashTable.contains(object))
  }
  
  /**
  func testWeakReference() {
    DispatchQueue.main.async {
      let object = TestClass()
      self.threadSafeHashTable.add(object)
      XCTAssertEqual(self.threadSafeHashTable.count, 1)
    }    
    // `object` should be released after its scope in the end of main runloop execution.
    let expectation = XCTestExpectation(description: "waitForAsync")
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      XCTAssertEqual(self.threadSafeHashTable.count, 0)
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: 10)
  }
 */  
  func testMultiThread() {
    let dispatchGroup = DispatchGroup()
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    
    // Test adding objects on multiple threads.
    let items = (0..<Self.total).map { _ in TestClass() }
    items.forEach { item in
      dispatchGroup.enter()
      queue.async {
        self.threadSafeHashTable.add(item)
        dispatchGroup.leave()
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` of threadSafeHashTable with the expected value.
    XCTAssertEqual(threadSafeHashTable.count, Self.total)
  }
}

private class TestClass {}

