import XCTest
@testable import CZUtils

class ThreadSafeDictionaryTests: XCTestCase {
  private static let queueLabel = "com.tony.test.threadSafeDictionary"
  private var queue: DispatchQueue!

  private var originalDict: [Int: Int] = {
    var originalDict = [Int: Int]()
    for (i, value) in (0 ..< 10).enumerated() {
      originalDict[i] = value
    }
    return originalDict
  }()

  func testSingleThreadInitializ() {
    let threadSafeDict = ThreadSafeDictionary<Int, Int>(dictionary: originalDict)
    XCTAssert(threadSafeDict.isEqual(toDictionary: originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
  }
  
  func testSingleThreadSetValue() {
    let threadSafeDict = ThreadSafeDictionary<Int, Int>()
    for (key, value) in originalDict {
      threadSafeDict[key] = value
    }
    XCTAssert(threadSafeDict.isEqual(toDictionary: originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
  }
  
  //  func testMultiThreadSetValueManyTimes() {
  //    (0..<300).forEach { _ in
  //      self.testMultiThreadSetValue()
  //    }
  //  }
  
  func testMultiThreadSetValue() {
    // Concurrent DispatchQueue to simulate multiple-thread read/write executions
    queue = DispatchQueue(
      label: Self.queueLabel,
      qos: .userInitiated,
      attributes: .concurrent)
    
    // 1. Initialize ThreadSafeDictionary
    let threadSafeDict = ThreadSafeDictionary<Int, Int>()

    // 2. Copy keys/values from `originalDict` to `threadSafeDict` on multi threads.
    // Group asynchonous write operations by DispatchGroup
    let dispatchGroup = DispatchGroup()
    for (key, value) in originalDict {
      dispatchGroup.enter()
      queue.async {
        // Sleep to simulate operation delay in multiple thread mode
        let sleepInternal = TimeInterval((arc4random() % 10)) * 0.00001
        Thread.sleep(forTimeInterval: sleepInternal)
        threadSafeDict[key] = value
        dispatchGroup.leave()
      }
    }
    
    // 3. DispatchGroup: Wait for completion signal of all operations
    dispatchGroup.wait()
    XCTAssert(
      threadSafeDict.isEqual(toDictionary: self.originalDict),
      "Result of ThreadSafeDictionary should same as the original dictionary.")
  }
}
