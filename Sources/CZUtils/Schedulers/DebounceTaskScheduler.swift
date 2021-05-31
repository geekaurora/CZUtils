import Foundation

/**
 Scheduler that merges the same tasks and only executes the last task.
 
 - Note: Task will execute on a background serial DispatchQueue.
 */
public class DebounceTaskScheduler {
  public typealias Task = () -> Void
  
  private let gap: TimeInterval
  /// Utilize DispatchSourceTimer as NSTime requires runloop associated with the same thread.
  private let timer: CZDispatchSourceTimer
  
  @ThreadSafe
  private var task: Task?
  
  public init(gap: TimeInterval) {
    self.gap = gap
    
    self.timer = CZDispatchSourceTimer(timeInterval: Int(gap))
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
