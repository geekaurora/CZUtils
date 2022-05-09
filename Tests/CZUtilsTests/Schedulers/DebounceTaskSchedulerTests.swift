import XCTest
@testable import CZUtils

/**
 - Note: Correct if only test itself.
 
 Test failure reason: normally the timer leeway <= internal * 2.
 */
class DebounceTaskSchedulerTests: XCTestCase {
  fileprivate enum Constant {
    static let interval = 0.1
    static let waitIntervalDelay = 0.1
    
    /// Normally the timer leeway <= internal * 0.3.
    static let timeOffset: TimeInterval = 0
  }
  
  //private let testQueue = DispatchQueue.main
  /// Background serial queue.
  private let testQueue = DispatchQueue(label: "com.testQueue")
  
  @ThreadSafe
  fileprivate var count = 0
  fileprivate var debounceTaskScheduler: DebounceTaskScheduler!
  
  override func setUp() {
    super.setUp()
    count = 0
  }
  
  func testOneTask() {
    debounceTaskScheduler = DebounceTaskScheduler(interval: Constant.interval)
    
    count = 0
    // Schedule task now
    scheduleCounterTask(after: 0)
    // Expected `count` = 1 now
    assertCount(equalsTo: 1, after: 0.1)
  }
  
  func testMultiTasks() {
    debounceTaskScheduler = DebounceTaskScheduler(interval: Constant.interval)
    
    count = 0
    // Schedule task now
    scheduleCounterTask(after: 0)
    // Expected `count` = 1 now
    assertCount(equalsTo: 1, after: 0.1)
    
    // Schedule task now
    scheduleCounterTask(after: 0.1)
    // Expected `count` = 2 now
    assertCount(equalsTo: 2, after: 0.2)
  }
  
  func testMultiTasksWithOverlapping() {
    debounceTaskScheduler = DebounceTaskScheduler(interval: Constant.interval)
    
    count = 0
    // Schedule task now
    scheduleCounterTask(after: 0)
    // Expected `count` = 1 now
    assertCount(equalsTo: 1, after: 0.1)
    
    // Schedule task at 0.1, 0.11, 0.12 - should be merged.
    scheduleCounterTask(after: 0.1)
    scheduleCounterTask(after: 0.11)
    scheduleCounterTask(after: 0.12)
    // Expected `count` = 2 now
    assertCount(equalsTo: 2, after: 0.2)
  }
  
}

// MARK: - Private methods

fileprivate extension DebounceTaskSchedulerTests {
  func incrementCount() {
    _count.threadLock{ (_count) -> Void in
      _count += 1
    }
  }
  
  func assertCount(equalsTo count: Int,
                   after delayTime: TimeInterval? = nil,
                   adjustTimeOffset: TimeInterval = Constant.timeOffset) {
    // Sync execution
    guard let inputDelayTime = delayTime else {
      XCTAssertTrue(count == self.count, "\(Date()) Error - actualCount = \(self.count); expectedCount = \(count)")
      return
    }
    // Async execution
    let delayTime = inputDelayTime + adjustTimeOffset
    testQueue.asyncAfter(deadline: DispatchTime.now() + delayTime) { [weak self] in
      guard let `self` = self else {
        return
      }
      XCTAssertTrue(count == self.count, "\(Date()) Error - actualCount = \(self.count); expectedCount = \(count)")
    }
  }
  
  func scheduleCounterTask(after delayTime: TimeInterval = 0) {
    if delayTime == 0 {
      debounceTaskScheduler.schedule {
        self.incrementCount()
      }
      return
    }
    testQueue.asyncAfter(deadline: DispatchTime.now() + delayTime) {
      self.debounceTaskScheduler.schedule {
        self.incrementCount()
      }
    }
  }
    
}

// MARK: - Helper methods

fileprivate extension DebounceTaskSchedulerTests {
  /**
   Convenient func for aysnc unit tests
   */
  func waitForInterval(_ interval: TimeInterval) {
    let expectation = XCTestExpectation(description: "waitForInterval")
    testQueue.asyncAfter(deadline: DispatchTime.now() + interval) {
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: interval + Constant.waitIntervalDelay)
  }
  
  /**
   Async task on mainQueue after desired time
   */
  func asyncOnMainQueue(after interval: TimeInterval, execute: @escaping () -> Void) {
    testQueue.asyncAfter(deadline: DispatchTime.now() + interval, execute: execute)
  }
}
