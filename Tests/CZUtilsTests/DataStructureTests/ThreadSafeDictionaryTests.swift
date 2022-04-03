import XCTest
@testable import CZUtils

class ThreadSafeDictionaryTests: XCTestCase {
  private static let queueLabel = "com.tony.test.threadSafeDictionary"
  private enum Constant {
    static let count = 30000 // 100
  }
  
  private let expectedDict: [Int: Int] = {
    var expectedDict = [Int: Int]()
    for (i, value) in (0..<Constant.count).enumerated() {
      expectedDict[i] = value
    }
    return expectedDict
  }()
  
  func testSingleThreadInitialization() {
    let threadSafeDict = ThreadSafeDictionary<Int, Int>(dictionary: expectedDict)
    XCTAssert(threadSafeDict.isEqual(toDictionary: expectedDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
  }
  
  func testSingleThreadSetValue() {
    let threadSafeDict = ThreadSafeDictionary<Int, Int>()
    for (key, value) in expectedDict {
      threadSafeDict[key] = value
    }
    XCTAssert(threadSafeDict.isEqual(toDictionary: expectedDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
  }
  
  //  func testMultiThreadSetValueManyTimes() {
  //    (0..<300).forEach { _ in
  //      self.testMultiThreadSetValue()
  //    }
  //  }
  
  func testMultiThreadSetValue() {
    // 1. Initialize ThreadSafeDictionary
    let threadSafeDict = ThreadSafeDictionary<Int, Int>()
    
    // Concurrent DispatchQueue to simulate multiple-thread read/write executions
    let queue = DispatchQueue(
      label: Self.queueLabel,
      qos: .userInitiated,
      attributes: .concurrent)
    
    // 2. Copy keys/values from `expectedDict` to `threadSafeDict` on multi threads.
    // Group asynchonous write operations by DispatchGroup
    let dispatchGroup = DispatchGroup()
    for (key, value) in expectedDict {
      dispatchGroup.enter()
      queue.async {
        // Sleep to simulate operation delay in multiple thread mode
        // let sleepInternal = TimeInterval((arc4random() % 10)) * 0.00001
        // Thread.sleep(forTimeInterval: sleepInternal)
        threadSafeDict[key] = value
        dispatchGroup.leave()
      }
    }
    
    // 3. DispatchGroup: Wait for completion signal of all operations
    dispatchGroup.wait()
    XCTAssert(threadSafeDict.isEqual(toDictionary: self.expectedDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
  }
}
