import XCTest
@testable import CZUtils

class CZDispatchSourceTimerTests: XCTestCase {
  fileprivate enum Constant {
    static let interval = 0.1
    static let waitIntervalDelay = 0.1
    static let timeOffset: TimeInterval = 0
    
    static let testTimes = 3
    static let expectationTimeout: TimeInterval = 10
  }
  
  @ThreadSafe
  fileprivate var count = 0
  fileprivate var czDispatchSourceTimer: CZDispatchSourceTimer!
  
  override func setUp() {
    super.setUp()
    count = 0
  }
  
  func testTicks() {
    let expectation = XCTestExpectation(description: "waitForInterval")
    
    let startDate = Date()
    // Start czDispatchSourceTimer with tickClosure.
    czDispatchSourceTimer = CZDispatchSourceTimer(timeInterval: Constant.interval, tickClosure: {
      self.count += 1
      dbgPrint("CZDispatchSourceTimer tick: count = \(self.count)")
      
      // Verify tickClosure is fired every `Constant.interval`.
      let timeElapsed = Date().timeIntervalSince(startDate)
      XCTAssertEqual(timeElapsed, TimeInterval(self.count) * Constant.interval)
      
      if self.count >= Constant.testTimes {
        expectation.fulfill()
      }
    })
    czDispatchSourceTimer.resume()
    
    wait(for: [expectation], timeout: Constant.expectationTimeout)
  }
    
}


//// MARK: - Helper methods
//
//fileprivate extension CZDispatchSourceTimerTests {
//  /**
//   Convenient func for aysnc unit tests
//   */
//  func waitForInterval(_ interval: TimeInterval) {
//    let expectation = XCTestExpectation(description: "waitForInterval")
//    testQueue.asyncAfter(deadline: DispatchTime.now() + interval) {
//      expectation.fulfill()
//    }
//    wait(for: [expectation], timeout: interval + Constant.waitIntervalDelay)
//  }
//
//  /**
//   Async task on mainQueue after desired time
//   */
//  func asyncOnMainQueue(after interval: TimeInterval, execute: @escaping () -> Void) {
//    testQueue.asyncAfter(deadline: DispatchTime.now() + interval, execute: execute)
//  }
//}
