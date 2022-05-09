import Foundation

/**
 Elegant thread safe timer.
 */
public class ThreadSafeTimer: NSObject {
  public typealias Tick = (ThreadSafeTimer) -> Void
  
  @ThreadSafe
  private var isStopped = false
  @ThreadSafe
  private var repeats: Bool
  
  
  /// The serial queue that executes `tick` closure with thread safety.
  let serialQueue: DispatchQueue
  let interval: TimeInterval
  let tick: Tick

  public init(interval: TimeInterval,
              repeats: Bool,
              tick: @escaping Tick) {
    self.interval = interval
    self.tick = tick
    self.repeats = repeats
    self.serialQueue = DispatchQueue(label: "com.ThreadSafeTimer")
    
    super.init()
  }
  
  deinit {
    stop()
  }
  
  /// Returns and starts a ThreadSafeTimer to execute `block` with the input params.
  ///
  /// - Note: You should retain the timer otherwise it will be deallocated.
  public class func scheduledTimer(
    withTimeInterval interval: TimeInterval,
    repeats: Bool,
    block: @escaping (ThreadSafeTimer) -> Void) -> ThreadSafeTimer {
      let timer = ThreadSafeTimer(interval: interval, repeats: repeats, tick: block)
      timer.start()
      return timer
    }
  
  public func start() {
    isStopped = false
    serialQueue.asyncAfter(deadline: .now() + interval, execute: _tick)
  }
  
  public func stop() {
    isStopped = true
  }
}

// MARK: - Private methods

private extension ThreadSafeTimer {
  private func _tick() {
    guard !isStopped else {
      return
    }
    
    let delayTime: DispatchTime = .now() + interval
    if repeats {
      serialQueue.asyncAfter(deadline: delayTime, execute: {
        self.tick(self)
        self._tick()
      })
    } else {
      serialQueue.asyncAfter(deadline: delayTime) {
        self.tick(self)
      }
    }
  }
}
