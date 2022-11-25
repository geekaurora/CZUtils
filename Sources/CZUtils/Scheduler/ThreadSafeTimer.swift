import Foundation

/**
 Elegant thread safe timer.
 */
public class ThreadSafeTimer: NSObject {
  public typealias Tick = (ThreadSafeTimer) -> Void
  
  @ThreadSafe
  private var isRunning = false
  @ThreadSafe
  private var repeats: Bool
  
  /// The serial queue that executes `tick` closure with thread safety.
  let serialQueue: DispatchQueue
  let interval: TimeInterval
  let tick: Tick
  
  /// Designated initializer.
  /// - Note: You should start the timer by calling `start()`.
  public init(interval: TimeInterval,
               repeats: Bool = true,
               tick: @escaping Tick) {
    self.interval = interval
    self.tick = tick
    self.repeats = repeats
    self.serialQueue = DispatchQueue(label: "com.ThreadSafeTimer")
    
    super.init()
  }
  
  /// Returns and starts a ThreadSafeTimer to execute `block` with the input params.
  ///
  /// - Note:
  /// 1. You should retain the timer otherwise it will be deallocated.
  /// 2. You should always capture [weak self] in `tick` closure to avoid the retain cycle.
  public class func scheduledTimer(
    interval: TimeInterval,
    repeats: Bool = true,
    tick: @escaping (ThreadSafeTimer) -> Void) -> ThreadSafeTimer {
      let timer = ThreadSafeTimer(
        interval: interval,
        repeats: repeats,
        tick: tick)
      timer.start()
      return timer
    }
  
  public func start() {
    guard !isRunning else {
      return
    }
    isRunning = true
    _tick()
  }
}

// MARK: - Private methods

private extension ThreadSafeTimer {
  private func _tick() {
    serialQueue.asyncAfter(deadline: .now() + interval) { [weak self] in
      guard let `self` = self else { return }
      self.tick(self)
      
      if self.repeats {
        // Note: calling `self._tick()` asynchronously won't cause recursion.
        self._tick()
      }
    }
  }
}
