import XCTest
@testable import CZUtils

class SimpleThreadLockTests: XCTestCase {
  static let total = 30000
  static let queueLable = "com.czutils.tests"
  
  var count: Int = 0
  let lock = SimpleThreadLock()
  
  func testMultiThread() {    
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
    sleep(UInt32.random(in: 0..<5) * UInt32(0.001))
    lock.execute {
      count += 1
    }
  }
}
