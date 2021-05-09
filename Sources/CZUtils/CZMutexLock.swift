//
//  CZMutexLock.swift
//
//  Created by Cheng Zhang on 1/4/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation

/// Generic multi-thread mutex lock on top of DispatchQueue sync/barrier
public class CZMutexLock<Item>: NSObject {
  /// `lock` should be initialized immediately to avoid crash if `lazy` load.
  ///
  /// Ticket: https://github.com/geekaurora/CZUtils/issues/13
  /// Note: The issue wasn't casued by DispatchQueue.async(flags: .barrier)
  private let lock = DispatchReadWriteLock()
  
  /// The underlying data item.
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
    return lock.read { [weak self] in
      guard let `self` = self else {
        assertionFailure("self was deallocated!")
        return nil
      }
      return block(self.item)
    }
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
    let isAsync = isAsync || self.shouldWriteBeAsync
    return lock.write(isAsync: isAsync) { [weak self] in
      guard let `self` = self else {
        assertionFailure("self was deallocated!")
        return nil
      }
      return block(&self.item)
    }
  }
}

public class DispatchReadWriteLock {
  private let syncQueue = DispatchQueue(label: "com.thread.mutexLock", attributes: .concurrent)
  public init () {}
  
  @discardableResult
  public func read<T>(_ block: @escaping () -> T?) -> T?  {
    return syncQueue.sync { () -> T? in
      return block()
    }
  }
  
  @discardableResult
  public func write<T>(isAsync: Bool = false, block: @escaping () -> T?) -> T? {
    if isAsync {
      syncQueue.async(flags: .barrier) { _ = block() }
      return nil
    } else {
      return syncQueue.sync(flags: .barrier) {() -> T? in
        return block()
      }
    }
  }
}

// MARK: - Bridging class for Objective-C

@objc public class CZMutexLockOC: NSObject {
  private var lock: CZMutexLock<Any>
  init(_ item: Any) {
    lock = CZMutexLock<Any>(item)
  }
  
  @discardableResult
  public func read (_ block: @escaping (_ item: Any) -> Any?) -> Any? {
    return lock.readLock {(item: Any) -> Any?  in
      return block(item)
    }
  }
  
  @discardableResult
  public func write(_ block: @escaping (_ item: Any) -> Any?) -> Any? {
    return lock.writeLock { (item: inout Any) -> Any? in
      return block(item)
    }
  }
}

