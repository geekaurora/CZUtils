import XCTest
@testable import CZUtils

class CADisplayLinkWeakReferenceTests: XCTestCase {
  private enum Constant {
    static let waitExpectationDescription = "waitForInterval"
    static let interval: TimeInterval = 30
  }
  
  fileprivate var dsplayLinkObserver: TestCADisplayLinkObserver?
  
  func testWeakReference() {
    let expectation = XCTestExpectation(description: Constant.waitExpectationDescription)
    
    dsplayLinkObserver = TestCADisplayLinkObserver()
    dsplayLinkObserver = nil
    
    wait(for: [expectation], timeout: Constant.interval)
    
    
  }
}

fileprivate class TestCADisplayLinkObserver: NSObject {
  private var displayLink: CADisplayLink?
  
  public override init() {
    super.init()
    
    self.displayLink = CADisplayLink.displayLinkWithWeakTarget(self, selector: #selector(tick(_:)))
    displayLink?.add(to: .main, forMode: .common)
  }
  
  // MARK: - CADisplayLink
  
  @objc func tick(_ displayLink: CADisplayLink) {}
}
