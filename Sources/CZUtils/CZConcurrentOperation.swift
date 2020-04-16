//
//  CZConcurrentOperation.swift
//
//  Created by Cheng Zhang on 1/5/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation

/// An abstract class that makes subclassing ConcurrentOperation easy to update KVO props `isReady`/`isExecuting`/`isFinished` automatically
///
/// Usage:
/// - Subclass must implement `execute()` when execute task
/// - Subclass must invoke `finish()` any work is done or after a call to `cancel()` to move the operation into a completed state.
@objc open class CZConcurrentOperation: Operation {
    /// Concurrent DispatchQueue acting as mutex read/write lock of rawState
    private let stateQueue = DispatchQueue(label: "com.tony.operation.state", attributes: [.concurrent])
    private var rawState: OperationState = .ready
    @objc dynamic var state: OperationState {
        get {
            return stateQueue.sync{ rawState}
        }
        set {
            willChangeValue(forKey: #keyPath(state))
            stateQueue.sync(flags: .barrier) {
                rawState = newValue
            }
            didChangeValue(forKey: #keyPath(state))
        }
    }
    public final override var isReady: Bool {
        return state == .ready && super.isReady
    }
    public final override var isExecuting: Bool {
        return state == .executing
    }
    public final override var isFinished: Bool {
        return state == .finished
    }
    public final override var isConcurrent: Bool {
        return true
    }
    
    // MARK: - Public Methods
    
    /// Subclasses must implement `execute` and must not call super
    open dynamic func execute() {
        fatalError("Subclasses must implement `\(#function)`.")
    }
    
    /// Call this function after any work is done or after a call to `cancel()`
    /// to move the operation into a completed state.
    public final dynamic func finish() {
        /**
         Cancelled operations can still be in Queue, should verify not `.finished` before cancel again
         ref: https://stackoverflow.com/questions/9409994/cancelling-nsoperation-from-nsoperationqueue-cause-crash
         */
        guard state != .finished else {
            return
        }
        // Set state to `.executing` if not before finish to avoid crash
        if !isExecuting  {
            state = .executing
        }
        state = .finished
    }
    
    // MARK: - Override methods
    public final override func start() {
        guard state != .finished else {
            return
        }
        if isCancelled {
            finish()
            return
        }
        state = .executing
        execute()
    }
    
    open override dynamic func cancel() {
        super.cancel()
        /**
         Invoke finish() only if it's `.excuting`, otherwise it will crash.
         For un-started operation, OperationQueue will start it after being cancelled. We can `finish()` it in `start()` if `isCancelled` is true
         ref: https://stackoverflow.com/questions/9409994/cancelling-nsoperation-from-nsoperationqueue-cause-crash
         */
        if isExecuting {
            finish()
        }
    }
    
    // MARK: - Dependent KVO
    
    /// Bind dependency of KVO between `state` and `isReady`, `isExecuting`,`isFinished`: `state` change automatically triggers KVO notification of the other 3 props
    @objc private dynamic class func keyPathsForValuesAffectingIsReady() -> Set<String> {
        return [#keyPath(state)]
    }
    @objc private dynamic class func keyPathsForValuesAffectingIsExecuting() -> Set<String> {
        return [#keyPath(state)]
    }
    @objc private dynamic class func keyPathsForValuesAffectingIsFinished() -> Set<String> {
        return [#keyPath(state)]
    }
}

@objc enum OperationState: Int {
    case ready = 0, executing, finished
}
