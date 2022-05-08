import XCTest
@testable import CZUtils

/**
 Correct when run separately, but incorrect with other tests - okay for now.
 */
class CZDispatchSourceTimerTests: XCTestCase {
  fileprivate enum Constant {
    static let interval = 0.01
    static let allowedLeeway = interval * 0.1
    
    static let testTimes = 50
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
    
    // Start czDispatchSourceTimer with tickClosure.
    let startDate = Date()
    czDispatchSourceTimer = CZDispatchSourceTimer(timeInterval: Constant.interval, tickClosure: {
      self.count += 1
      dbgPrint("CZDispatchSourceTimer tick: count = \(self.count)")
      
      // Verify tickClosure is fired every `Constant.interval`.
      let timeElapsed = Date().timeIntervalSince(startDate)
      let timeElapsedByTimer = TimeInterval(self.count - 1) * Constant.interval
      let actualLeeway = abs(timeElapsed - timeElapsedByTimer)
      XCTAssert(
        actualLeeway <= Constant.allowedLeeway,
        "actualLeeway doesn't match exptectedLeeway. actualLeeway = \(actualLeeway), exptectedLeeway = \(Constant.allowedLeeway)")
      
      if self.count >= Constant.testTimes {
        expectation.fulfill()
      }
    })
    czDispatchSourceTimer.resume()
    
    wait(for: [expectation], timeout: Constant.expectationTimeout)
  }
  
}
