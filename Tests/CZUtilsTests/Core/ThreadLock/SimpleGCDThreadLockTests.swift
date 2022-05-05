import XCTest
@testable import CZUtils

class SimpleGCDThreadLockTests: XCTestCase {
  private enum Constant {
    static let count = 1000
    static let queueLable = "com.czutils.tests"
  }
  
  private var queue: DispatchQueue!
  private var testArray: [Int]!
  private var threadLock: SimpleGCDThreadLock!
  
  override func setUp() {
    threadLock = SimpleGCDThreadLock()
    testArray = []
  }
  
  func testMultiThread() {
    queue = DispatchQueue(label: Constant.queueLable, attributes: .concurrent)
    let dispatchGroup = DispatchGroup()
    
    // Test adding objects on multiple threads.
    (0..<Constant.count).forEach { i in
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
    XCTAssertEqual(testArray.count, Constant.count)
  }
}
