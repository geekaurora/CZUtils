import XCTest
@testable import CZUtils

/// Tests of @ThreadSafe property wrapper.
class ThreadSafePropertyWrapperTests: XCTestCase {
  static let total = 30000
  static let queueLable = "com.czutils.tests"
  
  let lock = NSLock()
  var countWithLock: Int = 0
  @ThreadSafe var count: Int = 0
  
  override func setUp() {
    count = 0
    countWithLock = 0
  }
  
  // MARK: - Read
  
  func testReadMultiThread() {
    let dispatchGroup = DispatchGroup()
    
    // Test increment `count` on multiple threads.
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    (0..<Self.total).forEach { _ in
      dispatchGroup.enter()
      queue.async {
        self.increaseCount()
        
        // Verify read result of `count`.
        // Nested locks - should be the same order to avoid the dead lock.
        self.lock.lock()
        let countWithLock = self.countWithLock
        XCTAssertEqual(self.count, countWithLock)
        self.lock.unlock()
        dispatchGroup.leave()
        
        // Not work - different lock sessions.
        // XCTAssertEqual(self.count, self.count)
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` with the expected value.
    XCTAssertEqual(count, Self.total)
  }
  
  // MARK: - Write
  
  func testWriteMultiThread() {
    let dispatchGroup = DispatchGroup()
    
    // Test increment `count` on multiple threads.
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    (0..<Self.total).forEach { _ in
      dispatchGroup.enter()
      queue.async {
        self.increaseCount()
        dispatchGroup.leave()
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` with the expected value.
    XCTAssertEqual(count, Self.total)
  }
  
  /// Directly assign isn't thread safe.
  //  func testDirectlyAssignMultiThread() {
  //    let dispatchGroup = DispatchGroup()
  //
  //    // Test increment `count` on multiple threads.
  //    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
  //    (0..<Self.total).forEach { _ in
  //      dispatchGroup.enter()
  //      queue.async {
  //        self.count += 1
  //        dispatchGroup.leave()
  //      }
  //    }
  //    // Wait till group multi thread tasks complete.
  //    dispatchGroup.wait()
  //    // Verify `count` isn't `Self.total`.
  //    XCTAssertTrue(count != Self.total)
  //  }
}

// MARK: - Private methods

private extension ThreadSafePropertyWrapperTests {
  func increaseCount() {
    // Nested locks - should be the same order to avoid the dead lock.
    lock.lock()
    _count.threadLock { (_count) -> Void in
      _count += 1
      self.countWithLock = _count
    }
    lock.unlock()
  }
}
