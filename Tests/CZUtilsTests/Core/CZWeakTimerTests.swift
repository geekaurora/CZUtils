import XCTest
import CZTestUtils

@testable import CZUtils

class CZWeakTimerTests: XCTestCase {
  private enum Constant {
    static let timeout: TimeInterval = 30
  }
  var weakTimer: CZWeakTimer?
  fileprivate var testObject: TestClass?
  
  override func setUp() {}
  
  /// Verify the execution of the
  func testTimerExecution() {
    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Constant.timeout, testCase: self)
    
    // 0. Retains the `testObject`.
    testObject = TestClass()
    
    // 1. Fire the timer.
    weakTimer = CZWeakTimer.scheduledTimer(
      timeInterval: 1,
      target: testObject as Any,
      selector: #selector(TestClass.tick(_:)),
      userInfo: nil,
      repeats: true)
    
    MainQueueScheduler.asyncAfter(5) {
      // 3. Verify timer ticks more than 2 times.
      let actualTickCount = self.testObject?.tickCount ?? 0
      XCTAssert(actualTickCount > 2, "Expected tickCount = 2, Actual tickCount = \(actualTickCount)")
      
      // Fulfill the expectatation.
      expectation.fulfill()
    }
    
    // Wait for expectatation.
    waitForExpectatation()
  }
  
  /// Verify parent target of timer is weakly referenced.
  func testWeakTimer() {
    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Constant.timeout, testCase: self)
    
    // 0. Initialize the `testObject`.
    var testObject: TestClass? = TestClass()
    
    // 1. Fire the timer.
    weakTimer = CZWeakTimer.scheduledTimer(
      timeInterval: 1,
      target: testObject,
      selector: #selector(TestClass.tick(_:)),
      userInfo: nil,
      repeats: true)
    
    // 2. Release the parent target.
    testObject = nil
    
    MainQueueScheduler.asyncAfter(5) {
      // 3. Verify timer is invalidated and released after its parent target is released.
      XCTAssert(self.weakTimer?.underlyingTimer == nil, "underlyingTimer should have been invalidated and released.")
      
      let actualTickCount = self.testObject?.tickCount ?? 0
      XCTAssert(actualTickCount == 0, "Expected tickCount = 0, Actual tickCount = \(actualTickCount)")
      
      // Fulfill the expectatation.
      expectation.fulfill()
    }
    
    // Wait for expectatation.
    waitForExpectatation()
  }
  
}

fileprivate class TestClass {
  var tickCount = 0
  @objc
  func tick(_ timer: Timer) {
    dbgPrint("tick ..")
    tickCount += 1
  }
}
