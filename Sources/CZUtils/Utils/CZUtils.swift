//
//  Utils.swift
//  CZUtils
//
//  Created by Cheng Zhang on 2/19/18.
//  Copyright © 2018 Cheng Zhang. All rights reserved.
//

import Foundation

public class CZUtils {
  /// Returns the raw memory pointer of the `object`.
  ///
  /// - Note: the returned value isn't type safe nor automatically managed with ARC.
  public static func rawPointer(of object: AnyObject) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(object).toOpaque()
  }
}
