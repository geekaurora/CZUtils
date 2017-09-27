//
//  CriticalSectionLock.swift
//  CZUtils
//
//  Created by Cheng Zhang on 9/27/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit

open class CriticalSectionLock: NSLock {
    public func execute<T>(_ execution: () -> T)  -> T {
        lock()
        defer {
            unlock()
        }
        return execution()
    }
}
