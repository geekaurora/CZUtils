import Foundation

/**
 Scheduler that merges the same tasks and only executes the last task.
 */
public class DebounceTaskScheduler {
  public typealias Task = () -> Void
  private typealias TaskMap = [String: DatedTask]
  
  /**
   Task with schedule date, date is used to order tasks in ascending order. Refer to `postExecutionTaskMap` for details
   */
  private struct DatedTask {
    let date: Date
    let task: Task
  }
  
  public enum Constant {
    public static let maxEmptyExecutionCount = 5
    public static let workQueueName = "com.DebounceTaskScheduler"
  }
  
  private let gap: TimeInterval
  private let onMainThread: Bool
  private var workThread: Thread!
  // private let threadLock = DispatchReadWriteLock()
  
  private var executionTaskMap = TaskMap()
  private var postExecutionTaskMap = TaskMap()
  
  private var lastExecutionDate: Date = Date.distantPast
  private var schedulerTimer: Timer?
  private var emptyExecutionCounter: Int = 0
  
  private var hasScheduledExecution: Bool {
    return !executionTaskMap.isEmpty
  }
  private var workQueue: DispatchQueue?
  
  /**
   Initializer of task scheduler
   
   - parameter gap: the gap used to determin whether to execute task
   - parameter onMainThread: indicates whether schedule tasks on the main thread.
   */
  public init(gap: TimeInterval, onMainThread: Bool = true) {
    self.gap = gap
    self.onMainThread = onMainThread
    
    if onMainThread {
      self.workThread = Thread.current
    }
    else {
      // Initialize workQueue - serial DispatchQueue.
      workQueue = DispatchQueue(
        label: Constant.workQueueName,
        qos: .default,
        attributes: [])
      workQueue?.sync {
        self.workThread = Thread.current
      }
    }
  }
  
  /**
   Schedule execution task to the scheduler
   - parameter key    : the key used to de-dupe same execution. e.g. let key = #file + #function + String(#line)
   - parameter task: the execution task
   */
  public func schedule(key: String = #file + #function + String(#line),
                       task: @escaping Task) {
    if onMainThread {
      MainQueueScheduler.sync {
        self._schedule(key: key, task: task)
      }
    } else {
      workQueue?.async {
        self._schedule(key: key, task: task)
      }
    }
  }
  
  private func _schedule(key: String,
                         task: @escaping Task) {
    assert(workThread == Thread.current, "DebounceTaskScheduler should always work on the same thread.")
    
//    threadLock.write { [weak self] in
//      guard let `self` = self else { return }
      self.initializeTimerIfNeeded()
      
      let shouldExecuteImmediately = Date().timeIntervalSince(self.lastExecutionDate) >= self.gap
      if shouldExecuteImmediately {
        // Execute `task` immediately if the gap between now and `lastExecutionDate` is equal or greater than `gap`
        // Merge previous `executionBlock` into current execution
        self.executionTaskMap.removeValue(forKey: key)
        task()
        self.lastExecutionDate = Date()
        self.emptyExecutionCounter = 0
      } else {
        // Otherwise, schedule with `executionTaskMap` to execute on timer correspodingly
        self.executionTaskMap[key] = DatedTask(date: Date(), task: task)
      }
    
  //}
    
  }
  
  /**
   Time ticker executes `executionBlock` if exists with `gap` interval
   
   - parameter timer: the timer instance
   */
  @objc public func executeBlock(_ timer: Timer) {
    assert(workThread == Thread.current, "GapTaskScheduler should always work on the same thread.")

    //threadLock.write
    //{
      guard self.hasScheduledExecution else {
        self.emptyExecutionCounter += 1
        if self.emptyExecutionCounter >= Constant.maxEmptyExecutionCount {
          self.schedulerTimer?.invalidate()
          self.schedulerTimer = nil
        }
        return
      }
      // Execute normal tasks
      self.executeExecutions()
      
      self.lastExecutionDate = Date()
      self.emptyExecutionCounter = 0
    //}

  }
  
  func executeExecutions() {
    executeTaskMap(executionTaskMap) { self.executionTaskMap = $0 }
  }
  
  /**
   `inout` isn't pass-by-reference, it's mutable shadow copy and will be written back immediately after execution.
   By for asynchronous execution, no way to write back as expected, so need to copy input param and set it back
   in `completion` block.
   https://stackoverflow.com/questions/39569114/swift-3-0-error-escaping-closures-can-only-capture-inout-parameters-explicitly
   */
  private func executeTaskMap(_ taskMap: TaskMap,
                              completion: @escaping (TaskMap) -> Void) {
    // Add `taskMap` to capature list as a copy.
    //threadLock.write { [taskMap] in
      var taskMapCopy = taskMap
      // Execute tasks in ascending order of schedule date
      taskMapCopy.values.sorted(by: { (execution0, execution1) -> Bool in
        return execution0.date < execution1.date
      }).forEach { execution in
        execution.task()
      }
      
      // Reset `taskMap` after execution
      taskMapCopy.removeAll()
      
      // Send the copy back to change the original instance.
      completion(taskMapCopy)
    //}
  }
}

// MARK: - Private methods

private extension DebounceTaskScheduler {
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
    RunLoop.current.add(schedulerTimer, forMode: RunLoop.Mode.common)
  }
}
