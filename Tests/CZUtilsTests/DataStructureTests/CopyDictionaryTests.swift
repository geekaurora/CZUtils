import XCTest
@testable import CZUtils

class DictionaryExtensionTests: XCTestCase {
  
  override func setUp() {}
    
  func testDeepCopyWithClass() {
    var dict = [AnyHashable: NSCopying]()
    let testObject = TestClass(value: 1)
    dict["a"] = testObject

    let dictCopy = dict.deepCopy()
    var actual = (dictCopy["a"] as? TestClass)?.value
    XCTAssertTrue(actual == 1)
    
    // - Note: Shallow copy.
    (dict["a"] as? TestClass)?.value = 2
    actual = (dictCopy["a"] as? TestClass)?.value
    XCTAssertTrue(actual == 1)
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
