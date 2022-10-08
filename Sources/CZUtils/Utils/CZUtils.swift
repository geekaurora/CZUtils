//
//  Utils.swift
//  CZUtils
//
//  Created by Cheng Zhang on 2/19/18.
//  Copyright © 2018 Cheng Zhang. All rights reserved.
//

import Foundation

@objc
public class CZUtils: NSObject {
  /// Returns the raw memory pointer of the `object`.
  ///
  /// - Note: the returned value isn't type safe nor automatically managed with ARC.
  @objc
  public static func rawPointer(of object: AnyObject) -> UnsafeMutableRawPointer {
    return Unmanaged.passUnretained(object).toOpaque()
  }

  /// Returns whether the mode is running unit tests.
  @objc
  public static func isUnitTesting() -> Bool {
    let environment = ProcessInfo.processInfo.environment
    let testConfigPath = environment["XCTestConfigurationFilePath" ]
    return testConfigPath != nil;
  }
}
