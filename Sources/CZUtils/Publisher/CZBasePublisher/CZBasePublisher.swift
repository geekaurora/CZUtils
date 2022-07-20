import Foundation

/**
 Generic base publisher that supports customization of notifying subscribers.
 You should override notifySubscribers() in your subclass.
 
 ### Usage
 1. Subclass Publisher:
 class TextChangePublisher: CZBasePublisher<TextChangeObserverProtocol> {
   static let shared = TextChangePublisher()
   
   func notifyTextDidChange(text: String?) {
     subscribers.allObjects.forEach {
       $0.textDidChange(text: text)
     }
   }
 }

 2. Define ObserverProtocol :
 public protocol TextChangeObserverProtocol {
   func textDidChange(text: String?)
 }
 
 3. Conform to ObserverProtocol
 
 4. Add observer:
 `TextChangePublisher.shared.addObserver()`
 
 5. Notify observers:
 `TextChangePublisher.shared.notifyTextDidChange(text:)`
 */
open class CZBasePublisher<SubscriberType> {
  public private(set) var subscribers = ThreadSafeWeakArray<SubscriberType>(allowDuplicates: false)

  public init() {}

  // MARK: - Subscriber
  
  /// Notify `subscribers.allObjects` that observed event occurs.
  open func notifySubscribers() {
    assertionFailure("You should override notifySubscribers() in your subclass.")
  }
  
  open func addSubscriber(_ subscriber: SubscriberType) {
    subscribers.append(subscriber)
  }

  open func removeSubscriber(_ subscriber: SubscriberType) {
    subscribers.remove(subscriber)
  }

  open func removeAllSubscribers() {
    subscribers.removeAll()
  }
}
