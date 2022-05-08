import XCTest

@testable import CZUtils

final class LatencyMemoryCacheTests: XCTestCase {
  private enum Constant {
    static let queueLabel = "com.iga.cache"
    static let count = CZUnitTestConstants.concurrentCount
    static let testKey = 12
    static let testValue = 54
  }
  private var queue: DispatchQueue!
  private var latencyMemoryCache: LatencyMemoryCache<Int, Int>!

  private static let expectedDict: [Int: Int] = (0..<Constant.count).reduce(into: [:]) { dict, i in
    dict[i] = i
  }
  
  override func setUp() {
    latencyMemoryCache = LatencyMemoryCache<Int, Int>()
  }

  // MARK: - setObject tests

  func testSetObjectOnSingleThread() {
    // Set key/value to latencyMemoryCache with Constant.testValue/Constant.testKey.
    latencyMemoryCache.setObject(Constant.testValue, forKey: Constant.testKey)
    
    // Verify the result.
    let actual = latencyMemoryCache.object(forKey: Constant.testKey)
    XCTAssertEqual(actual, Constant.testValue, "Incorrect result! expected = \(Constant.testValue), actual = \(String(describing: actual))")
  }

  func testSetObjectWithNil() {
    // Set Constant.testValue for Constant.testKey in latencyMemoryCache.
    latencyMemoryCache.setObject(Constant.testValue, forKey: Constant.testKey)
    var actual = latencyMemoryCache.object(forKey: Constant.testKey)
    XCTAssertEqual(actual, Constant.testValue, "Incorrect result! expected = \(Constant.testValue), actual = \(String(describing: actual))")

    // Set value nil for Constant.testKey in latencyMemoryCache.
    latencyMemoryCache.setObject(nil, forKey: Constant.testKey)

    // Verify the result: the value of Constant.testKey should have been removed.
    actual = latencyMemoryCache.object(forKey: Constant.testKey)
    XCTAssertEqual(actual, nil, "Incorrect result! expected = \(Constant.testValue), actual = \(String(describing: actual))")
    XCTAssertFalse(latencyMemoryCache.dictionary.keys.contains(Constant.testKey), "latencyMemoryCache shouldn't contain the key \(Constant.testKey).")
  }
  
  func testSetObjectOnMultiThreads() {
    // Create a queue to write concurrently on multi threads.
    queue = DispatchQueue(label: Constant.queueLabel, attributes: .concurrent)

    // Set keys/values to latencyMemoryCache with `expectedDict` on multi threads.
    let dispatchGroup = DispatchGroup()
    for (key, value) in Self.expectedDict {
      dispatchGroup.enter()
      queue.async {
        self.latencyMemoryCache.setObject(value, forKey: key)
        dispatchGroup.leave()
      }
    }
    
    // Wait for the completion of all write operations.
    dispatchGroup.wait()
    
    // Verify the result.
    XCTAssertEqual(
      latencyMemoryCache.dictionary,
      Self.expectedDict,
      "Incorrect result! expected = \(Self.expectedDict), actual = \(latencyMemoryCache.dictionary)")
  }

  // MARK: - containsObject tests

  func testContainsObjectDisableAllowCacheNilObject() {
    latencyMemoryCache = LatencyMemoryCache<Int, Int>(allowCacheNilObject: false)

    // Set key/value to latencyMemoryCache with Constant.testValue/Constant.testKey.
    latencyMemoryCache.setObject(Constant.testValue, forKey: Constant.testKey)

    // Verify the result.
    var isContained = latencyMemoryCache.containsObject(forKey: Constant.testKey)
    XCTAssertTrue(isContained, "The cache should contain object for key = \(Constant.testKey).")

    // Set nil value for Constant.testKey.
    latencyMemoryCache.setObject(nil, forKey: Constant.testKey)

    // Verify the result.
    isContained = latencyMemoryCache.containsObject(forKey: Constant.testKey)
    XCTAssertFalse(isContained, "The cache shouldn't contain object for key = \(Constant.testKey).")
  }

  func testContainsObjectEnableAllowCacheNilObject() {
    latencyMemoryCache = LatencyMemoryCache<Int, Int>(allowCacheNilObject: true)

    // Set nil value for Constant.testKey.
    latencyMemoryCache.setObject(nil, forKey: Constant.testKey)

    // Verify the result.
    let isContained = latencyMemoryCache.containsObject(forKey: Constant.testKey)
    XCTAssertTrue(isContained, "The cache should contain object for key = \(Constant.testKey).")
  }
}
