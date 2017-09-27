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
    fileprivate var semaphore: DispatchSemaphore
    fileprivate var notifyQueue: DispatchQueue?
    fileprivate var notifyBlock: (() -> Void)?
    
    override init() {
        lock = CriticalSectionLock()
        semaphore = DispatchSemaphore(value: 0)
        underlyingQueue = DispatchQueue(label: CZDispatchGroup.underlyingQueueLabel,
                                             qos: .default,
                                             attributes: .concurrent)
        super.init()
    }
    
    public func enter() {
        underlyingQueue.async {[weak self] in
            self?.semaphore.wait()
        }
    }
    
    public func leave() {
        underlyingQueue.async {[weak self] in
            self?.semaphore.signal()
        }
    }
    
    public func wait() {
        semaphore.wait()
        semaphore.signal()
    }
    
    public func notify(qos: DispatchQoS = .default,
                       flags: DispatchWorkItemFlags = .inheritQoS,
                       queue: DispatchQueue,
                       execute work: @escaping @convention(block) () -> Void) {
        self.notifyQueue = queue
        self.notifyBlock = work
        
        // Wait for semaphore signal of completion of all executions
        underlyingQueue.async {[weak self] in
            guard let `self` = self else {return}
            self.semaphore.wait()
            self.semaphore.signal()
        }
        
    }
}

