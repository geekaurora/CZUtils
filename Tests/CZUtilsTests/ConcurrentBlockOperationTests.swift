import XCTest
@testable import CZUtils

fileprivate var executionIds = [Int]()
fileprivate let threadLock = SimpleThreadLock()
fileprivate var concurrentOperationTest: ConcurrentBlockOperationTests?

class ConcurrentBlockOperationTests: XCTestCase {
  static let total = 25
  static let queueLable = "com.czutils.operationQueue"
  let semaphore = DispatchSemaphore(value: 0)
  var operationQueue: OperationQueue!
  
  var operationsMap = [Int: Operation]()
  @ThreadSafe var finishedOperationIds = Set<Int>()
  
  override func setUp() {
    operationQueue = OperationQueue()
    operationQueue.name = Self.queueLable
    operationQueue.maxConcurrentOperationCount = 1
    
    operationsMap.removeAll()
    executionIds = []
    finishedOperationIds.removeAll()
    concurrentOperationTest = self
  }
  
  // MARK: - Test ConcurrentBlockOperation
  
  func testExecuteConcurrentOperationsInOperationQueue() {
    // 1. Add operations to operationQueue.
    let operationIds = Array(0..<Self.total)
    operationIds.forEach { id in
      let operation = TestConcurrentOperation(id: id)
      operationQueue.addOperation(operation)
      // Add self as KVO observer to `isFinished` property of `operation`.
      operation.addObserver(
        self,
        forKeyPath: #keyPath(ConcurrentBlockOperation.isFinished),
        options: [.old, .new],
        context: nil)
    }
    
    // 2. Wait till all operations finish.
    semaphore.wait()
    
    // 3. Verify executionIds have same sequence as operationIds.
    threadLock.execute {
      XCTAssertEqual(executionIds, operationIds)
    }
  }
  
  func testCancelConcurrentOperationsInOperationQueue() {
    // 1. Add operations to operationQueue.
    let operationIds = Array(0..<Self.total)
    operationIds.forEach { id in
      let operation = TestConcurrentOperation(id: id)
      operationsMap[id] = operation
      
      operationQueue.addOperation(operation)
      // Add self as KVO observer to `isFinished` property of `operation`.
      operation.addObserver(
        self,
        forKeyPath: #keyPath(ConcurrentBlockOperation.isFinished),
        options: [.old, .new],
        context: nil)
    }
    
    // 2. Cancel operations
    let operationIdsToCancel = Array(15..<Self.total)
    operationIdsToCancel.forEach { id in
      operationsMap[id]?.cancel()
    }
    let expectedOperationIds = operationIds.filter { !operationIdsToCancel.contains($0) }
    
    // 3. Wait till all operations finish.
    semaphore.wait()
    
    // 4. Verify executionIds have same sequence as operationIds.
    //
    // - Note:
    // Sometimes operations won't be cancelled because they already executed given
    // operation executes more than one at a time after cancelling - usually five operations
    // execute at the same time.
    threadLock.execute {
      // TODO:
      // 1). Operation executes more than one at a time after cancelling.
      // 2). Operation execution order after cancelling isn't as enqueued.
      XCTAssertEqual(executionIds.sorted(), expectedOperationIds.sorted())
    }
  }
  
  // MARK: - Private methods
  
  override func observeValue(forKeyPath keyPath: String?,
                             of object: Any?,
                             change: [NSKeyValueChangeKey : Any]?,
                             context: UnsafeMutableRawPointer?) {
    if keyPath == #keyPath(ConcurrentBlockOperation.isFinished),
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
fileprivate class TestConcurrentOperation: ConcurrentBlockOperation {
  let id: Int
  init(id: Int = 0) {
    self.id = id
    super.init()
  }
  
  deinit { removeObserver(concurrentOperationTest!, forKeyPath: #keyPath(isFinished)) }
  
  override func execute() {
    dbgPrint("\(#function) executing id = \(self.id)")
    usleep(UInt32(0.01 * 1000000))
    threadLock.execute {
      dbgPrint("\(#function) executed id = \(self.id)")
      executionIds.append(id)
      dbgPrint("\(#function) executionIds id = \(executionIds)")
    }
    
    DispatchQueue.global().async {
      self.finish()
    }
  }
}
