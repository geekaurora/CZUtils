import XCTest
import CZTestUtils

@testable import CZUtils

class CZWeakTimerTests: XCTestCase {
  private enum Constant {
    static let timeout: TimeInterval = 30
  }
  var weakTimer: CZWeakTimer?
  fileprivate var testObject: TestClass?
  
  override func setUp() {
    
  }
  
  func testWeakTimer() {
    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Constant.timeout, testCase: self)
    
    testObject = TestClass()
      
    weakTimer = CZWeakTimer.scheduledTimer(
      timeInterval: 1,
      target: testObject,
      selector: #selector(TestClass.tick(_:)),
      userInfo: nil,
      repeats: true)
    
    // Fulfill the expectatation.
    // expectation.fulfill()
    
    // Wait for expectatation.
    waitForExpectatation()
  }
    
}

fileprivate class TestClass {
  @objc
  func tick(_ timer: Timer) {
    dbgPrint("tick ..")
  }
  
}
