import XCTest
@testable import CZUtils

class TestThreadSafePropertyWrapper: XCTestCase {
  static let total = 30000
  static let queueLable = "com.czutils.tests"
  
  @ThreadSafe var count: Int = 0
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
    sleep(UInt32.random(in: 0..<50) * UInt32(0.001))
    // Note: ThreadSafe(wrappedValue: count) is immuable.
    // ThreadSafe(wrappedValue: count).execute { (count) in
    // count += 1
    // }
    count += 1
  }
}
