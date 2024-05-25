import XCTest
@testable import CZUtils

class CodableTests: XCTestCase {
  static let testDict: [String: String] = [
    "name": "Bob",
    "age": "12"
  ]

  // MARK: - Encodable

  func testDictionaryVersion() {
    let testObject = TestObject(name: Self.testDict["name"]!, age: Self.testDict["age"]!)
    let actual = testObject.dictionaryVersion as! [String: String]
    XCTAssertEqual(actual, Self.testDict)
  }

  // MARK: - Decodable

  func testDecodeFromJSONObject() {
    let testObject = TestObject(name: Self.testDict["name"]!, age: Self.testDict["age"]!)
    let dict = testObject.dictionaryVersion as! [String: String]
    let decodedTestObject = TestObject.decode(fromJSONObject: dict)
    XCTAssertEqual(testObject, decodedTestObject)
  }
}

private struct TestObject: Codable, Equatable {
  let name: String
  let age: String
}
