import XCTest
@testable import CZUtils

class DoubleExtensionTests: XCTestCase {
  
//  func testRound() {
//    let input = 5.4873
//    
//    var actual = input.roundedWithDecimal()
//    var expected = 5.5
//    XCTAssert(actual == expected, "Incorrect format! actual = \(actual), expected = \(expected)")
//        
//    actual = input.roundedWithDecimal(2)
//    expected = 5.49
//    XCTAssert(actual == expected, "Incorrect format! actual = \(actual), expected = \(expected)")
//    
//  }
  
    func testSystemRounded() {
      let input = 5.4873  
      let actual = input.rounded()
      let expected: Double = 5
      XCTAssert(actual == expected, "Incorrect result! actual = \(actual), expected = \(expected)")
    }
}
