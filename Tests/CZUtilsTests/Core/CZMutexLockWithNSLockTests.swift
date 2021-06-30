import XCTest
@testable import CZUtils

class CZMutexLockWithNSLockTests: XCTestCase {
  static let total = 30000
  static let queueLable = "com.czutils.tests"
  
  let lock = NSLock()
  var countWithLock: Int = 0
  
  @ThreadSafe var count: Int = 0
  // let countLock = CZMutexLockWithNSLock(0)
  
  override func setUp() {
    count = 0
    countWithLock = 0
  }
  
  func testReadMultiThread() {
    let dispatchGroup = DispatchGroup()
    
    // Test increment `count` on multiple threads.
    let queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    (0..<Self.total).forEach { _ in
      dispatchGroup.enter()
      queue.async {
        self.increaseCount()
        // Verify read result of `count`.
        self.lock.lock()
        XCTAssertEqual(self.count, self.countWithLock)
        self.lock.unlock()
        
        dispatchGroup.leave()
      }
    }
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // Verify `count` with the expected value.
    XCTAssertEqual(count, Self.total)
  }
  
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
  
  private func increaseCount() {
    // sleep(UInt32.random(in: 0..<5) * UInt32(0.001))
    _count.threadLock { (_count) -> Void in
      _count += 1
      
      lock.lock()
      self.countWithLock = _count
      lock.unlock()
    }
  }
}
