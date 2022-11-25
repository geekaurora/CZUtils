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
  
  /// A task to be executed in the next timer tick. It will be cleared after the execution.
  private var task: Task?
  
  private let threadLock = SimpleThreadLock()

  public init(interval: TimeInterval) {
    self.interval = interval
    super.init()

    self.timer = ThreadSafeTimer.scheduledTimer(interval: interval) { [weak self] _ in
      self?.tick()
    }
  }

  public func schedule(task: @escaping Task) {
    threadLock.execute { [weak self] in
      self?.task = task
    }
  }

  func tick() {
    // If task isn't nil, execute task() then set it to nil.
    threadLock.execute { [weak self] in
      self?.task?()
      self?.task = nil
    }
  }
}
