import Foundation

/**
 Scheduler that executes the task every `interval` time.
 
 - Note: Task will execute on `CZDispatchSourceTimer` which is built upon `DispatchSource`.
 */
public class DebounceTaskScheduler {
  public typealias Task = () -> Void
  
  private let interval: TimeInterval
  /// Utilize DispatchSourceTimer as NSTime requires runloop associated with the same thread.
  private let timer: CZDispatchSourceTimer
  
  @ThreadSafe
  private var task: Task?
  
  public init(interval: TimeInterval) {
    self.interval = interval
    
    self.timer = CZDispatchSourceTimer(timeInterval: interval)
    self.timer.tickClosure = { [weak self] in
      self?.tick()
    }
    self.timer.resume()
  }
  
  public func schedule(task: @escaping Task) {
    _task.threadLock { (_task) -> Void in
      _task = task
    }
  }
  
  func tick() {
    // If task isn't nil, execute task() then set it to nil.
    _task.threadLock { (_task) -> Void in
      if _task != nil {
        _task?()
        _task = nil
      }
    }
  }
  
}
