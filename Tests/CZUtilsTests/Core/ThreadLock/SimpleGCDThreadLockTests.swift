import XCTest
@testable import CZUtils

class SimpleGCDThreadLockTests: XCTestCase {
  static let total = 1000
  static let queueLable = "com.czutils.tests"
  
  private var queue: DispatchQueue!
  private var threadLock: SimpleGCDThreadLock!
  private var testArray: [Int]!
  
  override func setUp() {
    threadLock = SimpleGCDThreadLock()
    testArray = []
  }
  
  func testMultiThread() {
    queue = DispatchQueue(label: Self.queueLable, attributes: .concurrent)
    let dispatchGroup = DispatchGroup()
    
    // Test adding objects on multiple threads.
    (0..<Self.total).forEach { i in
      dispatchGroup.enter()
      
      queue.async {
        // 1. Write: append i to testArray.
        self.threadLock.write(isAsync: true) {
          self.testArray.append(i)
        }
        
        // 2. Read: verify i is written correctly.
        self.threadLock.read {
          XCTAssertTrue(self.testArray.contains(i), "testArray should contain i = \(i).")
        }
        dispatchGroup.leave()
      }
    }
    
    // Wait till group multi thread tasks complete.
    dispatchGroup.wait()
    // 3. Verify `count` of testArray with the expected value.
    XCTAssertEqual(testArray.count, Self.total)
  }
}
