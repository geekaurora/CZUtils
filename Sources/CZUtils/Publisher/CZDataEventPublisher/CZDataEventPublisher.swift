import CZUtils

/**
 Data event publisher that maintains the listeners and publishes data change events.
 */
public class CZDataEventPublisher {
  private var listeners = ThreadSafeWeakArray<CZDataEventListener>(allowDuplicates: false)
  
  public init() {}
  
  // MARK: - Event
  
  public func publishDataChange(_ data: CZEventData?) {
    listeners.allObjects.forEach { $0.handleUpdatedData(data) }
  }
  
  // MARK: - Listener
  
  public func addListener(_ listener: CZDataEventListener) {
    listeners.append(listener)
  }
  
  public func removeListener(_ listener: CZDataEventListener) {
    listeners.remove(listener)
  }
}
