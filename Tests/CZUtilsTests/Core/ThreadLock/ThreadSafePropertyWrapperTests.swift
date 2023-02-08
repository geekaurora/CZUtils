import XCTest
@testable import CZUtils

/// Tests of @ThreadSafe property wrapper.
class ThreadSafePropertyWrapperTests: XCTestCase {
  static let total = CZUnitTestConstants.concurrentCount
  static let queueLable = "com.czutils.tests"
  
  let lock = NSRecursiveLock()
  var countWithLock: Int = 0
  @ThreadSafe var count: Int = 0
  
  override func setUp() {
    count = 0
    countWithLock = 0
  }
  
  // MARK: - Read
  
  /**
   Verify directly get with `self.count` is thread safe.
   */
  func testReadOnMultiThreads() {
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
  
  /**
   Verify set with`self._count.threadLock {}` is thread safe. (Directly set isn't thread safe)
   */
  func testWriteOnMultiThreadsWithProjectedValue() {
    let dispatchGroup = DispatchGroup()
    
    // Test increment `count` on multiple threads.
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    (0..<Self.total).forEach { _ in
      dispatchGroup.enter()
      queue.async {
        self._count.threadLock { _count in
          _count += 1
        }
        dispatchGroup.leave()
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` with the expected value.
    XCTAssertEqual(count, Self.total)
  }
  
  /**
   Directly read and write at the same time isn't thread safe.
   Writing depends on the value from other lock session
   */
  func testWriteOnMultiThreadsDirectly() {
    let dispatchGroup = DispatchGroup()
    
    // Test increment `count` on multiple threads.
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    (0..<Self.total).forEach { _ in
      dispatchGroup.enter()
      queue.async {
        self.count = self.count + 1
        dispatchGroup.leave()
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` isn't `Self.total`.
    XCTAssertTrue(
      count != Self.total,
      "Incorrect result. expected = \(Self.total), actual = \(count)")
  }
}

// MARK: - Private methods

private extension ThreadSafePropertyWrapperTests {
  func increaseCount() {
    // Nested locks - should be the same order to avoid the dead lock.
    lock.lock()
    _count.threadLock { _count in
      _count += 1
      self.countWithLock = _count
    }
    lock.unlock()
  }
}
