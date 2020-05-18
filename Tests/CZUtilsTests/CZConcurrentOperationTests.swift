import XCTest
@testable import CZUtils

fileprivate var executionIds = [Int]()
fileprivate let threadLock = SimpleThreadLock()
fileprivate var concurrentOperationTest: CZConcurrentOperationTests?

class CZConcurrentOperationTests: XCTestCase {
  static let total = 20
  static let queueLable = "com.czutils.operationQueue"
  let semaphore = DispatchSemaphore(value: 0)
  @ThreadSafe var operationsMap = [Int: CZConcurrentOperation]()
  @ThreadSafe var finishedOperationIds = Set<Int>()
  
  override func setUp() {
    executionIds = []
    finishedOperationIds.removeAll()
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
      _operationsMap.threadLock { $0[id] = operation }
      
      operationQueue.addOperation(operation)
      // Add self as KVO observer to `isFinished` property of `operation`.
      operation.addObserver(
        self,
        forKeyPath: #keyPath(CZConcurrentOperation.isFinished),
        options: [.old, .new],
        context: nil)
    }
    
    // 3. Cancel operations
    let operationIdsToCancel = Array(15..<Self.total)
    operationIdsToCancel.forEach { id in
      _operationsMap.threadLock {
        let operation = $0[id]
        operation?.cancel()
      }
    }
    let expectedOperationIds = operationIds.filter { !operationIdsToCancel.contains($0) }
    
    // 4. Wait till all operations finish.
    semaphore.wait()
    
    // 5. Verify executionIds have same sequence as operationIds.
    // TODO: Operation execution order after cancelling isn't as enqueued.
    threadLock.execute {
      XCTAssertEqual(executionIds.sorted(), expectedOperationIds.sorted())
    }
  }
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if keyPath == #keyPath(CZConcurrentOperation.isFinished),
      let operation = object as? TestConcurrentOperation,
      let isFinished = change?[.newKey] as? Bool {
      
      _finishedOperationIds.threadLock{ finishedOperationIds in
        if (isFinished) {
          finishedOperationIds.insert(operation.id)
          // After the last operation executed, signal to unblock test to the verify the result.
          if (finishedOperationIds.count == Self.total) {
            semaphore.signal()
          }
        }
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
    dbgPrint("\(#function) executing id = \(self.id)")
    sleep(UInt32(0.1))
    threadLock.execute {
      dbgPrint("\(#function) executed id = \(self.id)")
      executionIds.append(id)
      dbgPrint("\(#function) executionIds id = \(executionIds)")
    }
    finish()
  }
  override func cancel() {
    finish()
  }
}
