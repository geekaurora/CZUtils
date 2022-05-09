import Foundation

/**
 Scheduler that executes the task every `interval` time.
 
 - Note: Task will execute on `CZDispatchSourceTimer` which is built upon `DispatchSourceTimer` and a serial background DispatchQueue.
 */
public class DebounceTaskScheduler: NSObject {
  public typealias Task = () -> Void
  
  private let interval: TimeInterval
  /// Utilize DispatchSourceTimer as NSTime requires runloop associated with the same thread.
  private var timer: ThreadSafeTimer!
  
  @ThreadSafe
  private var task: Task?
  
  public init(interval: TimeInterval) {
    self.interval = interval
    super.init()
    
    self.timer = ThreadSafeTimer.scheduledTimer(interval: interval) { [weak self] _ in
      self?.tick()
    }
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
