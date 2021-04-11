import XCTest
@testable import CZUtils

class CopyDictionaryTests: XCTestCase {
  
  override func setUp() {}
    
  /**
   Copy dictionary with String (Value type): deep copy.
   */
  func testCopyDictionaryWithString() {
    var dict = [AnyHashable: Any]()
    dict["a"] = "a"

    let dictCopy = dict
    XCTAssertTrue(dictCopy["a"] as? String == "a")
    
    dict["a"] = "b"
    XCTAssertTrue(dictCopy["a"] as? String  == "a")
  }
  
  /**
   Copy dictionary with Number (Value type): deep copy.
   */
  func testCopyDictionaryWithNumber() {
    var dict = [AnyHashable: Any]()
    dict["a"] = 1

    let dictCopy = dict
    XCTAssertTrue(dictCopy["a"] as? Int == 1)
    
    dict["a"] = 2
    XCTAssertTrue(dictCopy["a"] as? Int  == 1)
  }
  
  /**
   Copy dictionary with class value: shallow copies the class objcect, event Class conforms to `NSCopying`.
   */
  func testCopyDictionaryWithClass() {
    var dict = [AnyHashable: NSCopying]()
    let testObject = TestClass(value: 1)
    dict["a"] = testObject
    let isNSCopying = dict["a"] is NSCopying

    let dictCopy = dict
    var actual = (dictCopy["a"] as? TestClass)?.value
    XCTAssertTrue(actual == 1)
    
    // - Note: Shallow copy.
    (dict["a"] as? TestClass)?.value = 2
    actual = (dictCopy["a"] as? TestClass)?.value
    XCTAssertTrue(actual == 2)
  }
}

private class TestClass: NSObject, NSCopying {
  func copy(with zone: NSZone? = nil) -> Any {
    let copy = TestClass()
    copy.value = value
    return copy
  }
  
  var value: Int?
  init(value: Int? = nil) {
    self.value = value
  }
}
