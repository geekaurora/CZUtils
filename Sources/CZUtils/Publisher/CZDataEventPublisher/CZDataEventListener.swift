import CZUtils

public protocol CZDataEventListener: class {
  func handleUpdatedData(_ data: CZEventData?)
}
