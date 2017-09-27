//
//  TestThreadSafeDictionary.swift
//  CZUtils
//
//  Created by Cheng Zhang on 9/27/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import XCTest
@testable import CZUtils

class TestThreadSafeDictionary: XCTestCase {
    
    var originalDict: [Int: Int] = {
        var originalDict = [Int: Int]()
        for (i, value) in (0 ..< 10).enumerated() {
            originalDict[i] = value
        }
        return originalDict
    }()
    
    func testWithoutGCD() {
        let threadSafeDict = ThreadSafeDictionary<Int, Int>()
        for (key, value) in originalDict {
            threadSafeDict[key] = value
        }
        XCTAssert(threadSafeDict.isEqual(toDictionary: originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
    }
}
