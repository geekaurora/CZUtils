//
//  ThreadSafeDictionary.swift
//  CZUtils
//
//  Created by Cheng Zhang on 9/27/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit

class ThreadSafeDictionary<Key: Hashable, Value: Any>: NSObject, ExpressibleByDictionaryLiteral
    //, Collection
{
    typealias DictionaryType = Dictionary<Key, Value>
    fileprivate var protectedCache: CZMutexLock<DictionaryType>
    fileprivate var emptyDictionary = DictionaryType()
        
    override init() {
        protectedCache = CZMutexLock([:])
        super.init()
    }
    
    // MAKR: - ExpressibleByDictionaryLiteral
    
    /// Creates an instance initialized with the given key-value pairs.
    public required init(dictionaryLiteral elements: (Key, Value)...) {
        var dictionary = DictionaryType()
        for (key, value) in elements {
            dictionary[key] = value
        }
        protectedCache = CZMutexLock(dictionary)
        super.init()
    }
    
    // MARK: - Public variables
    public var isEmpty: Bool {
        return protectedCache.readLock { $0.isEmpty } ?? true
    }
    
    public var count: Int {
        return protectedCache.readLock { $0.count } ?? 0
    }
    
    public var keys: LazyMapCollection<[Key : Value], Key> {
        return protectedCache.readLock { $0.keys } ?? emptyDictionary.keys
    }

    public var values: LazyMapCollection<[Key : Value], Value> {
        return protectedCache.readLock { $0.values } ?? emptyDictionary.values
    }
    
    // MARK: Public methods
    public func updateValue(_ value: Value, forKey key: Key) -> Value? {
        return protectedCache.writeLock { $0.updateValue(value, forKey: key) }
    }
    
    public func removeValue(forKey key: Key) -> Value? {
        return protectedCache.writeLock { $0.removeValue(forKey: key) }
    }
    
    public func removeAll(keepingCapacity keepCapacity: Bool = true) {
         protectedCache.writeLock { $0.removeAll(keepingCapacity: keepCapacity) }
    }

    // MARK: - Subscripts
    
    public subscript (key: Key) -> Value? {
        return protectedCache.readLock { $0[key] }
    }
    
    public subscript(position: DictionaryIndex<Key, Value>) -> (key: Key, value: Value) {
        return protectedCache.readLock { return $0[position] }  ?? emptyDictionary[position]
    }

    
    // MARK: - Collection protocol
    
    public var startIndex: DictionaryIndex<Key, Value> {
        return protectedCache.readLock { $0.startIndex } ?? emptyDictionary.startIndex
    }

    public var endIndex: DictionaryIndex<Key, Value> {
        return protectedCache.readLock { $0.endIndex } ?? emptyDictionary.endIndex
    }
    
    public func indexForKey(_ key: Key) -> DictionaryIndex<Key, Value>? {
        return protectedCache.readLock { $0.index(forKey: key) }
    }
    
    public func index(after i: DictionaryIndex<Key, Value>) -> DictionaryIndex<Key, Value> {
        return protectedCache.readLock { $0.index(after: i) }  ?? emptyDictionary.index(after: i)
    }
}
