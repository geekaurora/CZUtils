import XCTest
@testable import CZUtils

class NSDispatchQueueTests: XCTestCase {
  private static let queueLabel = "com.tony.test.queue"
  private static let workQueueLabel = "com.tony.test.workQueue"
  
  private var queue: DispatchQueue!
  private var workQueue: DispatchQueue!
  
  private var originalDict: [Int: Int] = {
    var originalDict = [Int: Int]()
    for (i, value) in (0 ..< 10).enumerated() {
      originalDict[i] = value
    }
    return originalDict
  }()
  
  private var threadSafeDict: [Int: Int] = [:]
  
  /**
   Verify multiple tasks - workQueue.sync(.barrier) work correctly, after waiting for other .barrier tasks.
   
   ### Results
   
   - If there's .barrier task executing in DispatchQueue, other tasks will wait till the current .barrier task completes.
   - Multiple tasks - workQueue.sync(.barrier) work correctly.
   */
  func testMultiThreadSetValue() {
    // 1. Initialize ThreadSafeDictionary
    let threadSafeDict = ThreadSafeDictionary<Int, Int>()
    
    // Concurrent DispatchQueue to simulate multiple-thread read/write executions
    queue = DispatchQueue(label: Self.queueLabel,
                          qos: .userInitiated,
                          attributes: .concurrent)
    
    workQueue = DispatchQueue(label: Self.workQueueLabel,
                              qos: .userInitiated,
                              attributes: .concurrent)
    
    // 2. Copy keys/values from `originalDict` to `threadSafeDict` on multi threads.
    // Group asynchonous write operations by DispatchGroup
    let dispatchGroup = DispatchGroup()
    for (key, value) in originalDict {
      dispatchGroup.enter()
      queue.async {
        // Sleep to simulate operation delay in multiple thread mode
        let sleepInternal = TimeInterval((arc4random() % 100)) * 0.0001
        Thread.sleep(forTimeInterval: sleepInternal)
        
        self.workQueue.sync(flags: .barrier) {
          print("workQueue.sync(.barrier) - started. value = \(value)")
          Thread.sleep(forTimeInterval: 1)
          threadSafeDict[key] = value
          print("workQueue.sync(.barrier) - ended.")
        }
        
        dispatchGroup.leave()
      }
    }
    
    // 3. DispatchGroup: Wait for completion signal of all operations
    dispatchGroup.wait()
    XCTAssert(threadSafeDict.isEqual(toDictionary: self.originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
  }
}
