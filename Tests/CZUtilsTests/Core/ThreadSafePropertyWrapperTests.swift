import XCTest
@testable import CZUtils

/// Tests of @ThreadSafe property wrapper.
class ThreadSafePropertyWrapperTests: XCTestCase {
//   static let total = 30000
   static let total = 200
  static let queueLable = "com.czutils.tests"
  
  let lock = NSLock()
  var countWithLock: Int = 0
  
  @ThreadSafe var count: Int = 0
  @ThreadSafe var count2: Int = 0
  
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
//        self.lock.lock()
//        let countWithLock = self.countWithLock
//        self.lock.unlock()
//        XCTAssertEqual(self.count, countWithLock)
        
//        self._count.threadLock { (_count) -> Void in
//          self.lock.lock()
//          XCTAssertEqual(_count, self.countWithLock)
//          self.lock.unlock()
        
        XCTAssertEqual(self.count, self.count2)        
        
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
//      lock.lock()
      _count += 1
//      self.countWithLock = _count
//      lock.unlock()
      
      self.count2 = _count
    }
  }
}

