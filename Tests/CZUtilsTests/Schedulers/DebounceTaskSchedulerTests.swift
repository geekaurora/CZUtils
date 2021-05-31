import XCTest
@testable import CZUtils

class DebounceTaskSchedulerTests: XCTestCase {
  fileprivate enum Constant {
    static let gap = 0.1
    static let waitIntervalDelay = 0.1
    static let timeOffset: TimeInterval = 0
  }
  
  fileprivate var count = 0
  fileprivate var postExecutionCount = 0
  fileprivate var secondPostExecutionCount = 0
  fileprivate var gapTaskScheduler: DebounceTaskScheduler!
  
  override func setUp() {
    super.setUp()
    
    count = 0
    gapTaskScheduler = DebounceTaskScheduler(gap: Constant.gap)
  }
  
  func testTasksInCombinedGaps() {
    count = 0
    // Schedule task now
    scheduleCounterTask(after: 0)
    // Expected `count` = 1 now
    assertCount(equalsTo: 1)
    
    // Schedule task now again. As actualGap between first/second tasks < `gap`(0.1 sec), second task will be scheduled to next gap cycle
    gapTaskScheduler.schedule { [weak self] in
      self?.incrementCount()
    }
    // Expected `count` = 1 now
    assertCount(equalsTo: 1)
    // Expected `count` = 2 after 0.1 sec
    assertCount(equalsTo: 2, after: 0.10)
    
    // Tasks in `gap` [0, 0.1] sec should be delayed/merged and executed only once
    scheduleCounterTask(after: 0.03)
    scheduleCounterTask(after: 0.04)
    scheduleCounterTask(after: 0.05)
    // Expected `count` = 1 now
    assertCount(equalsTo: 1)
    // Expected `count` = 2 after 0.1 sec
    assertCount(equalsTo: 2, after: 0.10)
    
    // Tasks in `gap` [0.1, 0.2] sec should be delayed/merged and executed only once
    scheduleCounterTask(after: 0.13)
    scheduleCounterTask(after: 0.14)
    scheduleCounterTask(after: 0.15)
    // Expected `count` = 3 after 0.2 sec
    assertCount(equalsTo: 3, after: 0.20)
    
    // Schedule task at 0.32 sec, as last execution date is 0.20 sec, it should be executed immediately
    scheduleCounterTask(after: 0.32)
    // Expected `count` = 4 after 0.32 sec
    assertCount(equalsTo: 4, after: 0.32)
    // Expected `count` = 4 after 0.40 sec
    assertCount(equalsTo: 4, after: 0.40)
  }
}

// MARK: - Private methods

fileprivate extension DebounceTaskSchedulerTests {
  func incrementCount() {
    count += 1
  }
  
  func assertCount(equalsTo count: Int, after delayTime: TimeInterval? = nil, adjustTimeOffset: TimeInterval = Constant.timeOffset) {
    // Sync execution
    guard let inputDelayTime = delayTime else {
      XCTAssertTrue(count == self.count, "\(Date()) Error - actualCount = \(self.count); expectedCount = \(count)")
      return
    }
    // Async execution
    let delayTime = inputDelayTime + adjustTimeOffset
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) { [weak self] in
      guard let `self` = self else {
        return
      }
      XCTAssertTrue(count == self.count, "\(Date()) Error - actualCount = \(self.count); expectedCount = \(count)")
    }
  }
  
  func scheduleCounterTask(after delayTime: TimeInterval = 0) {
    if delayTime == 0 {
      gapTaskScheduler.schedule {
        self.incrementCount()
      }
      return
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
      self.gapTaskScheduler.schedule {
        self.incrementCount()
      }
    }
  }
  
  // MARK: - PostExecution
  
  func incrementPostExecutionCount() {
    postExecutionCount += 1
  }
  
  func incrementSecondPostExecutionCount() {
    secondPostExecutionCount += 1
  }
  
  func assertPostExecutionCount(equalsTo count: Int, after delayTime: TimeInterval? = nil, adjustTimeOffset: TimeInterval = Constant.timeOffset) {
    // Sync execution
    guard let inputDelayTime = delayTime else {
      XCTAssertTrue(count == self.postExecutionCount, "\(Date()) Error - actualCount = \(self.postExecutionCount); expectedCount = \(count)")
      return
    }
    // Async execution
    let delayTime = inputDelayTime + adjustTimeOffset
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) { [weak self] in
      guard let `self` = self else {
        return
      }
      XCTAssertTrue(count == self.postExecutionCount, "\(Date()) Error - actualCount = \(self.postExecutionCount); expectedCount = \(count)")
    }
  }
  
  func assertSecondPostExecutionCount(equalsTo count: Int, after delayTime: TimeInterval? = nil, adjustTimeOffset: TimeInterval = Constant.timeOffset) {
    // Sync execution
    guard let inputDelayTime = delayTime else {
      XCTAssertTrue(count == self.secondPostExecutionCount, "\(Date()) Error - actualCount = \(self.secondPostExecutionCount); expectedCount = \(count)")
      return
    }
    // Async execution
    let delayTime = inputDelayTime + adjustTimeOffset
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) { [weak self] in
      guard let `self` = self else {
        return
      }
      XCTAssertTrue(count == self.secondPostExecutionCount, "\(Date()) Error - actualCount = \(self.secondPostExecutionCount); expectedCount = \(count)")
    }
  }
  
  func schedulePostExecutionCounterTask(after delayTime: TimeInterval = 0) {
    let key = #file + #function
    if delayTime == 0 {
      gapTaskScheduler.schedulePostExecution(key: key) {
        self.incrementPostExecutionCount()
      }
      return
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
      self.gapTaskScheduler.schedulePostExecution(key: key) {
        self.incrementPostExecutionCount()
      }
    }
  }
  
  func schedulePostExecutionCounterTask2(after delayTime: TimeInterval = 0) {
    let key = #file + #function
    if delayTime == 0 {
      gapTaskScheduler.schedulePostExecution(key: key) {
        self.incrementSecondPostExecutionCount()
      }
      return
    }
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + delayTime) {
      self.gapTaskScheduler.schedulePostExecution(key: key) {
        self.incrementSecondPostExecutionCount()
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
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval) {
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: interval + Constant.waitIntervalDelay)
  }
  
  /**
   Async task on mainQueue after desired time
   */
  func asyncOnMainQueue(after interval: TimeInterval, execute: @escaping () -> Void) {
    DispatchQueue.main.asyncAfter(deadline: DispatchTime.now() + interval, execute: execute)
  }
}
