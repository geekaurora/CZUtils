//import XCTest
//@testable import CZUtils
//
///**
// - Note: Correct if only test itself.
// */
//class ThreadSafeTimerTests: XCTestCase {
//  fileprivate enum Constant {
//    static let interval = 0.01
//    /// - Note: Normally the leeway <= internal * 0.3 (0.5, 2).
//    static let allowedLeeway = interval * 0.3
//    
//    static let testTimes = 50
//    static let expectationTimeout: TimeInterval = 10
//  }
//  
//  @ThreadSafe
//  fileprivate var count = 0
//  @ThreadSafe
//  fileprivate var lastTickDate: Date!
//  fileprivate var threadSafeTimer: ThreadSafeTimer!
//  
//  override func setUp() {
//    super.setUp()
//    count = 0
//  }
//  
//  func testTicks() {
//    let expectation = XCTestExpectation(description: "waitForInterval")
//    
//    // Start threadSafeTimer with tickClosure.
//    lastTickDate = Date()
//    
//    threadSafeTimer = ThreadSafeTimer.scheduledTimer(interval: Constant.interval) { timer in
//      self.count += 1
//      // dbgPrint("ThreadSafeTimer tick: count = \(self.count)")
//      
//      // Verify tick is fired every `Constant.interval`.
//      let actualLeeway = abs(Date().timeIntervalSince(self.lastTickDate) - Constant.interval)
//      XCTAssert(
//        actualLeeway <= Constant.allowedLeeway,
//        "actualLeeway doesn't match exptectedLeeway. actualLeeway = \(actualLeeway), exptectedLeeway = \(Constant.allowedLeeway). count = \(self.count)")
//      self.lastTickDate = Date()
//      
//      if self.count >= Constant.testTimes {
//        expectation.fulfill()
//      }
//    }
//    
//    wait(for: [expectation], timeout: Constant.expectationTimeout)
//  }
//  
//}
