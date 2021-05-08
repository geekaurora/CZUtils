//
//  ThreadSafeDictionary.swift
//  CZUtils
//
//  Created by Cheng Zhang on 2/10/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation

/// Elegant thread safe Dictionary on top of CZMutexLock
open class ThreadSafeDictionary<Key: Hashable, Value: Any>: NSObject, Collection, ExpressibleByDictionaryLiteral {
  public typealias DictionaryType = Dictionary<Key, Value>
  
  /// The underlying dictionary with the thread safety.
  /// Update(2021-05-08): Convert thread lock from `CZMutexLock` to @ThreadSafe - fix crash of ThreadSafeDictionaryTests.testMultiThreadSetValue().
  @ThreadSafe
  private var protectedCache: DictionaryType
  private var underlyingDictionary: DictionaryType {
    return protectedCache
  }
  
  public override init() {
    protectedCache = [:]
    super.init()
  }
  
  public init(dictionary: DictionaryType) {
    protectedCache = dictionary
    super.init()
  }
  
  // MAKR: - ExpressibleByDictionaryLiteral
  
  /// Creates an instance initialized with the given key-value pairs
  public required init(dictionaryLiteral elements: (Key, Value)...) {
    var dictionary = DictionaryType()
    for (key, value) in elements {
      dictionary[key] = value
    }
    protectedCache = dictionary
    super.init()
  }
  
  // MARK: - Public variables
  
  public var isEmpty: Bool {
    return protectedCache.isEmpty
  }
  
  public var count: Int {
    return protectedCache.count
  }
  
  public var keys: Dictionary<Key, Value>.Keys {
    return protectedCache.keys
  }
  
  public var values: Dictionary<Key, Value>.Values {
    return protectedCache.values
  }
  
  // MARK: - Public methods
  
  public func updateValue(_ value: Value, forKey key: Key) -> Value? {
    return _protectedCache.threadLock{ (_protectedCache) -> Value? in
      return _protectedCache.updateValue(value, forKey: key)
    }
  }
  
  public func removeValue(forKey key: Key) -> Value? {
    return _protectedCache.threadLock{ (_protectedCache) -> Value? in
      return _protectedCache.removeValue(forKey: key)
    }
  }
  
  public func removeAll(keepingCapacity keepCapacity: Bool = false) {
    _protectedCache.threadLock { (_protectedCache) -> Void in
      return _protectedCache.removeAll(keepingCapacity: keepCapacity)
    }
  }
  
  public func values(for keys: [Key]) -> [Value] {
    return _protectedCache.threadLock { (_protectedCache) -> [Value] in
      return keys.compactMap { _protectedCache[$0] }
    }
  }
  
  // MARK: - Subscripts
  
  public subscript (key: Key) -> Value? {
    get {
      return protectedCache[key]
    }
    set {
      _protectedCache.threadLock { (_protectedCache) -> Void in
        _protectedCache[key] = newValue
      }
    }
  }
  
  public subscript(position: DictionaryIndex<Key, Value>) -> (key: Key, value: Value) {
    return protectedCache[position]
  }
  
  // MARK: - Collection protocol
  
  public var startIndex: DictionaryIndex<Key, Value> {
    return protectedCache.startIndex
  }
  
  public var endIndex: DictionaryIndex<Key, Value> {
    return protectedCache.endIndex
  }
  
  public func indexForKey(_ key: Key) -> DictionaryIndex<Key, Value>? {
    return protectedCache.index(forKey: key)
  }
  
  public func index(after i: DictionaryIndex<Key, Value>) -> DictionaryIndex<Key, Value> {
    return protectedCache.index(after: i)
  }
  
  public func removeAtIndex(_ index: DictionaryIndex<Key, Value>) -> (Key, Value) {
    _protectedCache.threadLock { (_protectedCache) -> (Key, Value) in
      return _protectedCache.remove(at: index)
    }
  }
  
  // MARK: - CustomStringConvertable
  
  open override var description: String {
    _protectedCache.threadLock { (_protectedCache) -> String in
      var description = "[\n"
      var index = 0
      for (key, value) in _protectedCache {
        let comma = (index == _protectedCache.count - 1) ? "" : ","
        description += "\(key): \(value)\(comma)\n"
        index += 1
      }
      description += "]"
      return description
    }
  }
}

public extension ThreadSafeDictionary where Key : Hashable, Value : Equatable {
  static func ==(lhs: ThreadSafeDictionary, rhs: ThreadSafeDictionary) -> Bool {
    return lhs.underlyingDictionary == rhs.underlyingDictionary
  }
  
  func isEqual(toDictionary dictionary: DictionaryType) -> Bool {
    return underlyingDictionary == dictionary
  }
}


