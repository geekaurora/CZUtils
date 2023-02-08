import Foundation

/// Generic thread safe memory cache for the latency improvements.
internal class LatencyMemoryCache<Key: Hashable, Value>: NSObject {
  private let mutexLock = MutexThreadLock()

  private(set) var dictionary = [Key: Value]()
  private(set) var keysSet = Set<Key>()
  private let allowCacheNilObject: Bool

  /// The designated initializer of the cache.
  /// - Parameter allowCacheNilObject: Indicates whether allows to record nil object being set to the cache. Defaults to false.
  /// If `allowCacheNilObject` is true, containsObject(forKey:) will return true for the `key` whose object has been explicitly set including nil.
  public init(allowCacheNilObject: Bool = false) {
    self.allowCacheNilObject = allowCacheNilObject
    super.init()
  }

  /// Returns the object for the `key` if exists, nil otherwise.
  public func object(forKey key: Key) -> Value? {
    return mutexLock.execute {
      dictionary[key]
    }
  }

  /// Sets the `object` for the `key`.
  public func setObject(_ object: Value?, forKey key: Key) {
    mutexLock.execute {
      dictionary[key] = object
      if allowCacheNilObject {
        keysSet.insert(key)
      }
    }
  }

  /// Returns whether the cache contains the object for the `key`.
  /// - Note: if `allowCacheNilObject` is true, it will return true for the `key` whose object has been explicitly set including nil.
  public func containsObject(forKey key: Key) -> Bool {
    if allowCacheNilObject {
      return keysSet.contains(key)
    } else {
      return dictionary.keys.contains(key)
    }
  }
}

/// Convenience mutex lock that automatically unlocks when completes the execution.
///
/// ### Usage
/// ```
/// mutexLock.execute {
///   // Add your code here which is thread safe.
/// }
/// ```
private class MutexThreadLock: NSRecursiveLock {
  func execute<T>(_ execution: () -> T) -> T {
    lock()
    defer {
      unlock()
    }
    return execution()
  }
}
