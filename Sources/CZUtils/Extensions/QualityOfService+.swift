import Foundation

/**
 Convenient methods of QualityOfService.
 */
extension QualityOfService: CustomStringConvertible {
  public var description: String {
    switch self {
    case .userInteractive:
      return "userInteractive"
    case .userInitiated:
      return "userInitiated"
    case .utility:
      return "utility"
    case .background:
      return "background"
    case .`default`:
      return "default"
    @unknown default:
      return "unknown"
    }
  }
}
