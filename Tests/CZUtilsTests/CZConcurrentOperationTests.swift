import XCTest
@testable import CZUtils

fileprivate var executionIds: [Int] = []
fileprivate let threadLock = SimpleThreadLock()
fileprivate var concurrentOperationTest: CZConcurrentOperationTests?

class CZConcurrentOperationTests: XCTestCase {
  static let total = 20
  static let queueLable = "com.czutils.operationQueue"
  let semaphore = DispatchSemaphore(value: 0)
  
  override func setUp() {
    concurrentOperationTest = self
  }
  
  func testExecuteConcurrentOperationsInOperationQueue() {
    // 1. Initialize operationQueue.
    let operationQueue = OperationQueue()
    operationQueue.name = Self.queueLable
    operationQueue.maxConcurrentOperationCount = 1
    
    // 2. Add operations to operationQueue.
    let operationIds = Array(0..<Self.total)
    operationIds.forEach { id in
      let operation = TestConcurrentOperation(id: id)
      operationQueue.addOperation(operation)
      // Add self as KVO observer to `isFinished` property of `operation`.
      operation.addObserver(
        self,
        forKeyPath: #keyPath(CZConcurrentOperation.isFinished),
        options: [.old, .new],
        context: nil)
    }
    
    // 3. Wait till all operations finish.
    semaphore.wait()
    // 4. Verify executionIds have same sequence as operationIds.
    threadLock.execute {
      XCTAssertEqual(executionIds, operationIds)
    }
  }
  
  func testCancelConcurrentOperationsInOperationQueue() {
    // 1. Initialize operationQueue.
    let operationQueue = OperationQueue()
    operationQueue.name = Self.queueLable
    operationQueue.maxConcurrentOperationCount = 1
    
    // 2. Add operations to operationQueue.
    let operationIds = Array(0..<Self.total)
    operationIds.forEach { id in
      let operation = TestConcurrentOperation(id: id)
      operationQueue.addOperation(operation)
      // Add self as KVO observer to `isFinished` property of `operation`.
      operation.addObserver(
        self,
        forKeyPath: #keyPath(CZConcurrentOperation.isFinished),
        options: [.old, .new],
        context: nil)
    }
    
    // 3. Wait till all operations finish.
    semaphore.wait()
    // 4. Verify executionIds have same sequence as operationIds.
    threadLock.execute {
      XCTAssertEqual(executionIds, operationIds)
    }
  }
  
  // TODO: test cancel() method.
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if keyPath == #keyPath(CZConcurrentOperation.isFinished),
      let operation = object as? TestConcurrentOperation,
      let isFinished = change?[.newKey] as? Bool {
      if operation.id == Self.total - 1 && isFinished {
        // After the last operation executed, signal to unblock test to the verify the result.
        semaphore.signal()
      }
    }
  }
}

@objc
fileprivate class TestConcurrentOperation: CZConcurrentOperation {
  let id: Int
  init(id: Int = 0) { self.id = id }
  deinit { removeObserver(concurrentOperationTest!, forKeyPath: #keyPath(isFinished)) }
  
  override func execute() {
    sleep(UInt32.random(in: 0...10) * UInt32(0.001))
    threadLock.execute {
      executionIds.append(id)
    }
    finish()
  }
  override func cancel() {
    finish()
  }
}
