import Foundation

enum CZUnitTestConstants {
  /// The default concurrent count for multiple threading unit tests.
  /// - Note: Should avoid overloading the OS thread pool.
  static let concurrentCount = 50
}
