import Foundation

/**
 Generic base bublisher that can be subclassed to customize how to notify subscribers.
 You should implement notifySubscribers() in your subclass.
 */
open class CZBasePublisher<SubscriberType> {
  public private(set) var subscribers = ThreadSafeWeakArray<SubscriberType>(allowDuplicates: false)

  public init() {}

  // MARK: - Subscriber
  
  /// Notify all subscribers that the observed event occurs.
  open func notifySubscribers() {
    assertionFailure("You should implement notifySubscribers() in your subclass.")
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
