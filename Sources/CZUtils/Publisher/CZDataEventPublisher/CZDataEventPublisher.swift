import Foundation

/**
 Data event publisher that maintains the listeners and publishes data change events.
 
 ### Usage
 ```
  // Initialize publisher.
  var dataEventPublisher = CZDataEventPublisher()
 
   // Adds listener to `dataEventPublisher`.
   testCZDataEventListener = TestCZDataEventListener()
   dataEventPublisher.addListener(testCZDataEventListener)
 
   class TestCZDataEventListener: CZDataEventListener {
     var data: String?
     
     func handleUpdatedData(_ data: CZEventData?) {
       guard let data = (data as? String).assertIfNil else {
         return
       }
       self.data = data
     }
  }
 
 class TestData {
  var nameEventPublisher: CZDataEventPublisher?
  var name: String? {
    didSet {
      nameEventPublisher!.publishDataChange(name)
    }
  }
 }
 ```
 */
public class CZDataEventPublisher<EventData: CZEventData> {
  private var listeners = ThreadSafeWeakArray<CZDataEventListener>(allowDuplicates: false)
  
  public init() {}
  
  // MARK: - Event
  
  public func publishDataChange(_ data: EventData?) {
    listeners.allObjects.forEach {
      $0.handleUpdatedData(data)      
    }
  }
  
  // MARK: - Listener
  
  public func addListener(_ listener: CZDataEventListener) {
    listeners.append(listener)
  }
  
  public func removeListener(_ listener: CZDataEventListener) {
    listeners.remove(listener)
  }
  
  public func removeAllListeners() {
    listeners.removeAll()
  }
}
