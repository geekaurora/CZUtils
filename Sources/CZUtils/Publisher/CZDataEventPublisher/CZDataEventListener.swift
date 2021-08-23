import Foundation

public protocol CZDataEventListener: class {
  func handleUpdatedData(_ data: CZEventData?)
}
