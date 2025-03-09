import XCTest

@testable import CZUtils

class TaskGroupAsyncStreamHelperTests: XCTestCase {
  private static let timeout: TimeInterval = 20
  private static let testRange = 0..<10

  override func setUp() {}

  func testMakeAsyncStream() async {
    let (waitForExpectatation, expectation) = CZTestUtils.waitWithInterval(Self.timeout, testCase: self)

    Task {
      let models = Array(Self.testRange)
      let results = await runAsyncStream(models: models)
      // Verify the results.
      XCTAssertEqual(Set(models), Set(results))

      // Fulfill the expectatation.
      expectation.fulfill()
    }

    // Wait for the expectatation.
    waitForExpectatation()
  }

  // MARK: - Helper

  func runAsyncStream(models: [Int]) async -> [Int] {
    var results = [Int]()
    for await result in makeStream(models: models) {
      results.append(result!)
    }
    return results
  }

  func makeStream(models: [Int]) -> AsyncStream<Int?> {
    return TaskGroupAsyncStreamHelper.makeAsyncStream(
      taskModels: models,
      asyncTaskBlock: fetchTask)
  }

  /// Fetches the second level subtasks for the `searchSubtask`.
  func fetchTask(model: Int) async -> Int? {
    return model
  }
}
