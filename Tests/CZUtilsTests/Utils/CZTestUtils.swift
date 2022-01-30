import Foundation
import XCTest

public class CZTestUtils {
  public typealias WaitExpectation = () -> Void
  private enum Constant {
    static let waitExpectationDescription = "waitForInterval"
  }
  
  /**
   Returns tuple of`WaitExpectation` closure and XCTestExpectation.
   
   ### Usage
   ```
   // 1. Intialize the async expectation.
   let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(1, testCase: self)

   // 2. Wait for the expectatation.
   waitForExpectatation()
   
   // 3. Fulfill the expectatation.
   expectation.fulfill()
   ```
   
   - Parameters:
     - interval: the internal of timeout
     - testCase: the testCase which contains expectation
   - Returns: Tuple of`WaitExpectation` closure and XCTestExpectation.
              Should call `WaitExpectation` closure to make`testCase` waiting before timeout of `interval`.

   */
  public static func waitWithInterval(_ interval: TimeInterval,
                                      testCase: XCTestCase) -> (WaitExpectation, XCTestExpectation) {
    let expectation = XCTestExpectation(description: Constant.waitExpectationDescription)
    let waitExpectation: WaitExpectation = {
      testCase.wait(for: [expectation], timeout: interval)
    }
    return (waitExpectation, expectation)
  }
}
