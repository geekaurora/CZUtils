//import XCTest
//@testable import CZUtils
//
///**
// Correct when run itself separately, but incorrect with other tests.
// Ok - results are correct.
// */
//class CZDispatchSourceTimerTests: XCTestCase {
//  fileprivate enum Constant {
//    static let interval = 0.01
//    /// - Note: Normally the leeway <= internal * 2.
//    static let allowedLeeway = interval * 5
//    
//    static let testTimes = 50
//    static let expectationTimeout: TimeInterval = 10
//  }
//  
//  @ThreadSafe
//  fileprivate var count = 0
//  @ThreadSafe
//  fileprivate var lastTickDate: Date!
//  fileprivate var czDispatchSourceTimer: CZDispatchSourceTimer!
//  
//  override func setUp() {
//    super.setUp()
//    count = 0
//  }
//  
//  func testTicks() {
//    let expectation = XCTestExpectation(description: "waitForInterval")
//    
//    // Start czDispatchSourceTimer with tickClosure.
//    lastTickDate = Date()
//    czDispatchSourceTimer = CZDispatchSourceTimer(timeInterval: Constant.interval, tickClosure: {
//      self.count += 1
//      dbgPrint("CZDispatchSourceTimer tick: count = \(self.count)")
//      
//      // Verify tickClosure is fired every `Constant.interval`.
//      let actualLeeway = abs(Date().timeIntervalSince(self.lastTickDate) - Constant.interval)
//      XCTAssert(
//        actualLeeway <= Constant.allowedLeeway,
//        "actualLeeway doesn't match exptectedLeeway. actualLeeway = \(actualLeeway), exptectedLeeway = \(Constant.allowedLeeway)")
//      
//      self.lastTickDate = Date()
//      if self.count >= Constant.testTimes {
//        expectation.fulfill()
//      }
//    })
//    czDispatchSourceTimer.resume()
//    
//    wait(for: [expectation], timeout: Constant.expectationTimeout)
//  }
//  
//}
