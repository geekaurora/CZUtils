import XCTest
@testable import CZUtils

class SimpleGCDThreadLockTests: XCTestCase {
  static let total = 300
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
        self.threadLock.write(isAsync: false) {
          self.testArray.append(i)
        }
        self.threadLock.read {
          let expected = i + 1
          XCTAssertTrue(
            self.testArray.count == expected,
            "Incorrect testArray.count. expected = \(expected), actual = \(self.testArray.count)"
          )
        }
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
