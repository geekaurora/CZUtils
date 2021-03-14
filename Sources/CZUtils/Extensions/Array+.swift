//
//  Array+Extensoin.swift
//  CZUtils
//
//  Created by Cheng Zhang on 1/26/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import Foundation

public extension Array {
  /**
   Returns element at specified `safe` index if exists, otherwise nil
   
   e.g. let val = array[safe: 2] ?? 0
   */
  subscript (safe index: Index) -> Element? {
    return indices.contains(index) ? self[index] : nil
  }
  
  /**
   Pretty formatted description string
   */
  var prettyDescription: String {
    return Pretty.describing(self)
  }

  /**
   Returns the first item that matches type `T` if exists, nil otherwise.
   */
  func firstTyped<T>(_ matchBlock: (Element) -> T?) -> T? {
    for item in self where matchBlock(item) != nil {
      return matchBlock(item)
    }
    return nil
  }

  /**
   Removes the specified `object` from array.
   */
  mutating func remove(_ object: Element) {
    guard let index = firstIndex(where: { $0 as AnyObject === object as AnyObject }) else {
      return
    }
    remove(at: index)
  }
  
  /**
   Returns whether `self` equals to `array`.
   
   - Note: It will compare each individual item object within two arrays, instead of values.
   */
  func isEqualTo(_ array: [Any]) -> Bool {
    guard count == array.count else {
      return false
    }
    for (i, item) in enumerated() {
      let otherItem = array[i]
      if type(of: item) != type(of: otherItem) ||
        item as AnyObject !== otherItem as AnyObject {
        return false
      }
    }
    return true
  }
}

public extension Array where Element: NSCopying {
  func copy(with zone: NSZone? = nil) -> Any {
    return compactMap{ $0.copy() }
  }
}
