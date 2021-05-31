import Foundation

/**
 Task scheduler on current thread which merges same tasks within configured `gap`

 - Execute `block` immediately if the gap between now and `lastExecutionDate` is equal or greater than `gap`
 - Otherwise, schedule `executionBlock` to execute on timer correspodingly with `gap` interval

 ### Note
 - Timer will be invalidated/released after `maxEmptyExecutionCount` idle gaps, starts again on newly scheduled task
 */
public class GapTaskScheduler {
    public typealias GapTaskSchedulerBlock = () -> Void
    public enum Constant {
        static let maxEmptyExecutionCount = 5
    }
    fileprivate let gap: TimeInterval
    fileprivate var executionBlock: GapTaskSchedulerBlock?
    fileprivate var lastExecutionDate: Date = Date.distantPast
    fileprivate var schedulerTimer: Timer?
    fileprivate var emptyExecutionCounter: Int = 0

    /**
     Initializer of task scheduler

     - parameter gap: the gap used to determin whether to execute task
     */
    public init(gap: TimeInterval) {
        self.gap = gap
    }

    /**
     Schedule execution block to the scheduler

     - parameter block: the execution block
     */
    public func schedule(_ block: @escaping GapTaskSchedulerBlock) {
        initializeTimerIfNeeded()

        let shouldExecuteImmediately = Date().timeIntervalSince(lastExecutionDate) >= gap
        if  shouldExecuteImmediately {
            // Execute `block` immediately if the gap between now and `lastExecutionDate` is equal or greater than `gap`
            // Merge previous `executionBlock` into current execution
            executionBlock = nil
            block()
            lastExecutionDate = Date()
            emptyExecutionCounter = 0
        } else {
            // Otherwise, schedule `executionBlock` to execute on timer correspodingly
            executionBlock = block
        }
    }

    /**
     Time ticker executes `executionBlock` if exists with `gap` interval

     - parameter timer: the timer instance
     */
    @objc public func executeBlock(_ timer: Timer) {
        guard let executionBlock = executionBlock else {
            emptyExecutionCounter += 1
            if emptyExecutionCounter >= Constant.maxEmptyExecutionCount {
                schedulerTimer?.invalidate()
                schedulerTimer = nil
            }
            return
        }
        executionBlock()
        lastExecutionDate = Date()
        emptyExecutionCounter = 0

        // Remove `executionBlock` after execution
        self.executionBlock = nil
    }
}

// MARK: - Private methods

fileprivate extension GapTaskScheduler {
    func initializeTimerIfNeeded() {
        guard schedulerTimer == nil else {
            return
        }
        schedulerTimer = Timer.scheduledTimer(
            timeInterval: gap,
            target: self,
            selector: #selector(executeBlock(_:)),
            userInfo: nil,
            repeats: true)
        emptyExecutionCounter = 0

        guard let schedulerTimer = schedulerTimer else {
            return
        }

        // Runloop of background thread is attached during thread instantiation,
        // but isn't started by default, `run()` it to receive timer events
        if RunLoop.current != RunLoop.main {
            RunLoop.current.run()
        }

        // Scrolling changes Runloop mode from `Default` to `EventTracking`, which ignores timer events
        // So we need to mannually enable timer for scrolling by set corresponding Runloop mode for timer
        RunLoop.current.add(schedulerTimer, forMode: RunLoopMode.commonModes)
    }
}
