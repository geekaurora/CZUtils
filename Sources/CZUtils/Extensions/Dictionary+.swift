//
//  Dictionary+Extension.swift
//  CZUtils
//
//  Created by Cheng Zhang on 1/29/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import Foundation

public extension Dictionary {
  /// Retrieve value from `dotedKey`, compatible with multi-dot in keyPath. e.g. "user.profile.fullName"
  func value(forDotedKey dotedKey: String) -> Value? {
    return value(forSegmentedKey: dotedKey)
  }
  
  /// Retrieve value from `segmentedKey`, compatible with multi-segments separated by `splitter`. e.g. "user.profile.fullName", "user/profile/fullName"
  func value(forSegmentedKey segmentedKey: String, splitter: String = ".") -> Value? {
    var value: Any? = nil
    var dict: Dictionary? = self
    
    for subkey in segmentedKey.components(separatedBy: splitter) {
      guard dict != nil, let subkey = subkey as? Key else {
        return nil
      }
      value = dict?[subkey]
      dict = value as? Dictionary
    }
    return (value is NSNull) ? nil : (value as? Value)
  }
  
  /// Insert key/value pairs with input Dictionary
  mutating func insert(_ other: Dictionary) {
    for (key, value) in other {
      self[key] = value
    }
  }
  
  /// Returns the description sorted by dictionary keys.
  var descriptionSortedByKey: String {
    return self.descriptionSortedByKey() ?? ""
  }
  
  func descriptionSortedByKey(currLevel: Int = 0) -> String? {
    guard let dictionary = self as? [AnyHashable: CustomStringConvertible] else {
      return nil
    }
    let sortedKeys: [AnyHashable] = {
      if let keys = Array(dictionary.keys) as? [String] {
        return keys.sorted()
      } else {
        return Array(dictionary.keys)
      }
    }()
    
    let indent = Array(repeating: "  ", count: currLevel).joined(separator: "")
    let body = sortedKeys.map { key in
      let value: String = {
        var value = dictionary[key]!
        // If `value` is Dictionary, recursively sorted its keys and get description.
        if let subDictionary = value as? [AnyHashable: Any] {
          value = subDictionary.descriptionSortedByKey(currLevel: currLevel + 1)
        }
        return String(describing: value)
      }()
      return"\(indent)  \(key): \(value)"
    }.joined(separator: ",\r\n")
    
    let res = """
{
\(body)
\(indent)}
"""
    return res
  }
  
  /// Pretty formatted description string
  var prettyDescription: String {
    return Pretty.describing(self)
  }
  
  var description: String {
    return prettyDescription
  }
  
  /// Returns stringified version.
  var stringifyVersion: String? {
    return CZHTTPJsonSerializer.stringify(self)
  }
}
