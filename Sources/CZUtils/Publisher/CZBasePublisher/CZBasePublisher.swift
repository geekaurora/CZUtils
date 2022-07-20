import Foundation

public class CZBasePublisher<SubscriberType> {
  private var subscribers = ThreadSafeWeakArray<SubscriberType>(allowDuplicates: false)

  public init() {}

  // MARK: - Subscriber

  public func addSubscriber(_ subscriber: SubscriberType) {
    subscribers.append(subscriber)
  }

  public func removeSubscriber(_ subscriber: SubscriberType) {
    subscribers.remove(subscriber)
  }

  public func removeAllSubscribers() {
    subscribers.removeAll()
  }
}
