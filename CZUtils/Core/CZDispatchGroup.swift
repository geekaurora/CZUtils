//
//  CZDispatchGroup.swift
//  CZUtils
//
//  Created by Cheng Zhang on 9/27/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit

public final class CZDispatchGroup: NSObject {
    fileprivate static let underlyingQueueLabel = "com.tony.dispatchGroup"
    fileprivate let lock: CriticalSectionLock
    fileprivate var underlyingQueue: DispatchQueue
    fileprivate var semaphore: DispatchSemaphore?
    fileprivate var notifyQueue: DispatchQueue?
    fileprivate var notifyBlock: (() -> Void)?
    fileprivate var executionCount: Int {
        get { return lock.execute{ return _executionCount } }
        set { lock.execute { _executionCount = newValue } }
    }
    fileprivate var _executionCount: Int = 0
    
    override init() {
        lock = CriticalSectionLock()
        underlyingQueue = DispatchQueue(label: CZDispatchGroup.underlyingQueueLabel,
                                             qos: .default,
                                             attributes: .concurrent)
        super.init()
    }
    
    public func enter() {
        executionCount += 1
//        underlyingQueue.async {[weak self] in
//            //self?.semaphore.wait()
//        }
    }
    
    public func leave() {
        executionCount -= 1
        if executionCount == 0 {
            semaphore?.signal()
        }
        //        underlyingQueue.async {[weak self] in
        //            self?.semaphore.signal()
        //        }
    }
    
    public func wait() {
        semaphore = DispatchSemaphore(value: 0)
        semaphore?.wait()
    }
    
//    public func notify(qos: DispatchQoS = .default,
//                       flags: DispatchWorkItemFlags = .inheritQoS,
//                       queue: DispatchQueue,
//                       execute work: @escaping @convention(block) () -> Void) {
//        self.notifyQueue = queue
//        self.notifyBlock = work
//        
//        // Wait for semaphore signal of completion of all executions
//        underlyingQueue.async {[weak self] in
//            guard let `self` = self else {return}
//            self.semaphore.wait()
//            self.semaphore.signal()
//        }
//    }
    
    
}

