import Foundation

/**
 Thread safe scheduler that executes the`task` (if exists) once every `interval` time.
 
 - Note: The `task` will be reset to nil after the execution.
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
