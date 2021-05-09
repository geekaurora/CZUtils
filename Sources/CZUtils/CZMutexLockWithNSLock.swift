import Foundation

/// Generic multi-thread mutex lock on top of NSLock.
///
/// - Note: It's mainly for migrating CZMutexLock to NSLock with the same interface, and it doesn't support async write.
public class CZMutexLockWithNSLock<Item>: NSObject {
  /// The underlying data item.
  @ThreadSafe
  private var item: Item
  
  /// Indicates whether write lock is asynchronous. Defaults to false.
  private let shouldWriteBeAsync: Bool
  
  public init(_ item: Item,
              shouldWriteBeAsync: Bool = false) {
    self.item = item
    self.shouldWriteBeAsync = shouldWriteBeAsync
  }
  
  /// Execute `block` with read lock that protects `item`
  @discardableResult
  public func readLock<Result>(_ block: @escaping (_ item: Item) -> Result?) -> Result? {
    return _item.threadLock({ (_item) -> Result? in
      return block(_item)
    })
  }
  
  /// Execute `block` with write lock that protects `item`
  ///
  /// - Parameters:
  ///   - isAsync   : Whether should exectute `block` with the write lock asynchronously. Defaults to false.
  ///   - block       : the block to be executed.
  /// - Returns       : The returned result from `block` if any.
  @discardableResult
  public func writeLock<Result>(isAsync: Bool = false,
                                _ block: @escaping (_ item: inout Item) -> Result?) -> Result? {
    return _item.threadLock({ (_item) -> Result? in
      return block(&_item)
    })
  }
}
