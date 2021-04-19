import Foundation

/**
 Convenient methods of QueuePriority.
 */
extension Operation.QueuePriority: CustomStringConvertible {
  public var description: String {
    switch self {
    case .veryLow:
      return "veryLow"
    case .low:
      return "low"
    case .normal:
      return "normal"
    case .high:
      return "high"
    case .veryHigh:
      return "veryHigh"
    @unknown default:
      return "unknown"
    }
  }
}
