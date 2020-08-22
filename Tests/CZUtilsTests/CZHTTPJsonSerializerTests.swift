import XCTest
@testable import CZUtils

class CZHTTPJsonSerializerTests: XCTestCase {
  
  func testStringWithParams() {
    let params: [AnyHashable: Any] = [
      "parama": "parama",
      "param2": "param2",
      "paramb": "paramb",
      "paramc": "paramc",
      "param5": "param5",
      "a": "a",
      "param0": "param0",
    ]
    // Verify paramsKeys are sorted.
    let expected = "a=a&param0=param0&param2=param2&param5=param5&parama=parama&paramb=paramb&paramc=paramc"
    (0..<1000).forEach { _ in
      let actual = CZHTTPJsonSerializer.string(with: params)
      XCTAssert(actual == expected, "Actual result '\(actual ?? "")', Expected result = '\(expected)'")
    }
  }
}
