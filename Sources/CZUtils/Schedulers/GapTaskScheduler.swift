import Foundation

/**
 Task scheduler on current thread which merges same tasks within configured `gap`
 
 - Execute `task` immediately if the gap between now and `lastExecutionDate` is equal or greater than `gap`
 - Otherwise, schedule `executionBlock` to execute on timer correspodingly with `gap` interval
 
 ### Note
 - Timer will be invalidated/released after `maxEmptyExecutionCount` idle gaps, starts again on newly scheduled task
 */
public class GapTaskScheduler {
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
  }
  
  private let gap: TimeInterval
  private let onMainThread: Bool
  private var workThread: Thread
  // private let threadLock = DispatchReadWriteLock()
  
  /**
   Tasks that be scheduled immediately.
   */
  private var executionTaskMap = TaskMap()
  
  /**
   Tasks that only run after `executionTaskMap`. If `executionBlock` is empty, run immediately
   Utilize HashMap to ensure same tasks only execute once within Gap, e.g. if there're multiple `performBatchUpdates` scheduled to postExecutionTaskMap,
   only the last one will execute.
   
   ### Execution time complexity = O(nlgn)
   
   HashMap takes O(nlgn) to sort tasks based on its date when GapTaskScheduler executes tasks.
   If use array, when add new task we possibly need to check array.contains(task) = O(n) time and delete previous duplicate task = O(n) time,
   which takes overall O(2n^2) = O(n^2) time
   */
  private var postExecutionTaskMap = TaskMap()
  
  private var lastExecutionDate: Date = Date.distantPast
  private var schedulerTimer: Timer?
  private var emptyExecutionCounter: Int = 0
  
  private var hasScheduledExecution: Bool {
    return !executionTaskMap.isEmpty
  }
  
  /**
   Initializer of task scheduler
   
   - parameter gap: the gap used to determin whether to execute task
   - parameter onMainThread: indicates whether schedule tasks on the main thread.
   */
  public init(gap: TimeInterval, onMainThread: Bool = true) {
    self.gap = gap
    self.onMainThread = true
    self.workThread = Thread.current
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
      _schedule(key: key, task: task)
    }
  }
  
  private func _schedule(key: String,
                         task: @escaping Task) {
    assert(workThread == Thread.current, "GapTaskScheduler should always work on the same thread.")
    
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
   Schedule postExecution task to the scheduler, task that only runs after `executionBlock`. If `executionBlock` is nil, run immediately
   
   - parameter key    : the key used to de-dupe same postExecution. e.g. let key = #file + #function + String(#line)
   - parameter task  : the postExecution task
   */
  public func schedulePostExecution(key: String =  #file + #function + String(#line),
                                    task: @escaping Task) {
    if !hasScheduledExecution {
      task()
    } else {
      postExecutionTaskMap[key] = DatedTask(date: Date(), task: task)
    }
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
      // Execute post tasks after normal
      self.executePostExecutions()
      
      self.lastExecutionDate = Date()
      self.emptyExecutionCounter = 0
    //}

  }
  
  public static func taskKey(
    with key: String = "",
    prefix: String =  #file + #function + String(#line)) -> String {
    return prefix + key
  }
}

// MARK: - Private methods

private extension GapTaskScheduler {
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
  
  func executeExecutions() {
    executeTaskMap(executionTaskMap) { self.executionTaskMap = $0 }
  }
  
  func executePostExecutions() {
    executeTaskMap(postExecutionTaskMap) { self.postExecutionTaskMap = $0 }
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
