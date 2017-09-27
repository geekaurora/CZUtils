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
    fileprivate static let queueLabel = "com.tony.test,threadSafeDictionary"
    
    fileprivate var originalDict: [Int: Int] = {
        var originalDict = [Int: Int]()
        for (i, value) in (0 ..< 100000).enumerated() {// 100000
            originalDict[i] = value
        }
        return originalDict
    }()
    
    func testInitializerithoutGCD() {
        let threadSafeDict = ThreadSafeDictionary<Int, Int>(dictionary: originalDict)
        XCTAssert(threadSafeDict.isEqual(toDictionary: originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
    }
    
    func testSetValueWithoutGCD() {
        let threadSafeDict = ThreadSafeDictionary<Int, Int>()
        for (key, value) in originalDict {
            threadSafeDict[key] = value
        }
        XCTAssert(threadSafeDict.isEqual(toDictionary: originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
    }
    
    func testWithGCD() {
        // Initialize ThreadSafeDictionary
        let threadSafeDict = ThreadSafeDictionary<Int, Int>()
        
        // Concurrent DispatchQueue to simulate multiple-thread read/write executions
        let queue = DispatchQueue(label: TestThreadSafeDictionary.queueLabel,
                                  qos: .userInitiated,
                                  attributes: .concurrent)
        
        // Asynchonous write operations by concurrent DispatchQueue
        let dispathGroup = DispatchGroup()
        for (key, value) in originalDict {
            dispathGroup.enter()
            queue.async {
                // Sleep to simulate operation delay in multiple thread
//                let sleepInternal = TimeInterval((arc4random() % 10)) * 0.000001
//                Thread.sleep(forTimeInterval: sleepInternal)
                threadSafeDict[key] = value
                dispathGroup.leave()
            }
        }

        // DispatchGroup to wait for completion of all asynchronous operations
        dispathGroup.notify(queue: .main) {
            XCTAssert(threadSafeDict.isEqual(toDictionary: self.originalDict), "Result of ThreadSafeDictionary should same as the original dictionary.")
        }
    }
}
