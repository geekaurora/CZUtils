import XCTest
@testable import CZUtils

class CADisplayLinkWeakReferenceTests: XCTestCase {
  private enum Constant {
    static let waitExpectationDescription = "waitForInterval"
    static let interval: TimeInterval = 30
  }
  
  fileprivate var dsplayLinkObserver: TestCADisplayLinkObserver?
  fileprivate weak var displayLink: CADisplayLink?
  
  /**
   Veriy `tick(_:)` callback of CZDisplayLink observer gets callsed.
   */
  func testDisplayLinkTick() {
    let expectation = XCTestExpectation(description: Constant.waitExpectationDescription)
    dsplayLinkObserver = TestCADisplayLinkObserver()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 0.1) {
      XCTAssertTrue(self.dsplayLinkObserver?.tickCount ?? 0 > 0, "`tickCount` should be greater than 0.")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: Constant.interval)
  }
  
  /**
   Should wait for 5s before `displayLink` is nil.
   */
  
  func testWeakReference() {
    let expectation = XCTestExpectation(description: Constant.waitExpectationDescription)

    dsplayLinkObserver = TestCADisplayLinkObserver()
    displayLink = dsplayLinkObserver?.displayLink
    dsplayLinkObserver = nil

    // Should wait for 5s before `displayLink` is nil.
    DispatchQueue.main.asyncAfter(deadline: .now() + 5) {
      XCTAssertTrue(self.displayLink == nil, "`displayLink` should have been released.")
      expectation.fulfill()
    }
    wait(for: [expectation], timeout: Constant.interval)
  }
}

fileprivate class TestCADisplayLinkObserver: NSObject {
  fileprivate(set) var displayLink: CADisplayLink?
  fileprivate var tickCount = 0
  
  public override init() {
    super.init()
    
    self.displayLink = CADisplayLink.displayLinkWithWeakTarget(self, selector: #selector(tick(_:)))
    displayLink?.add(to: .main, forMode: .common)
  }
  
  // MARK: - CADisplayLink
  
  @objc func tick(_ displayLink: CADisplayLink) {
    tickCount += 1
  }
}
