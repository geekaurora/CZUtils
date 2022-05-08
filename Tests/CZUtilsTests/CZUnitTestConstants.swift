import Foundation

enum CZUnitTestConstants {
  /// The max concurrent count for unit tests.
  /// - Note: Should avoid overloading the OS thread pool.
  static let concurrentCount = 50
}
