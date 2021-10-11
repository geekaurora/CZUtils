import XCTest
@testable import CZUtils

final class CZDataEventPublisherTests: XCTestCase {
  enum Constant {
    static let testName = "testName"
  }
  fileprivate var dataEventPublisher: CZDataEventPublisher<String>!
  fileprivate var testCZDataEventListener: TestCZDataEventListener!
  fileprivate var testDataObject: TestData!
  
  override func setUp() {
    dataEventPublisher = CZDataEventPublisher<String>()
    
    testDataObject = TestData()
    testDataObject.nameEventPublisher = dataEventPublisher
  }
  
  func testPublishDataEvent() {
    // Adds listener to `dataEventPublisher`.
    testCZDataEventListener = TestCZDataEventListener()
    dataEventPublisher.addListener(testCZDataEventListener)
    
    // Update property of `testDataObject`.
    testDataObject.name = Constant.testName
    
    // Verify the listener gets notified with the updated `data`.
    XCTAssertTrue(testCZDataEventListener.data == Constant.testName)
  }
}

extension String: CZEventData { }

fileprivate class TestData {
  var nameEventPublisher: CZDataEventPublisher<String>?
  
  var name: String? {
    didSet {
      nameEventPublisher!.publishDataChange(name)
    }
  }
}

fileprivate class TestCZDataEventListener: CZDataEventListener {
  var data: String?
  
  func handleUpdatedData(_ data: CZEventData?) {
    guard let data = (data as? String).assertIfNil else {
      return
    }
    self.data = data
  }  
}
