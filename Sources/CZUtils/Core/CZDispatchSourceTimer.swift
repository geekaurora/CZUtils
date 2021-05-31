import Foundation

/**
 Timer implemented with DispatchSourceTimer, which executes tick closure on a serial DispatchQueue.
 
 - Note: Should call `timer.resume()` to start the timer.
 
 ### Usage
 
 ```
 let timer = CZDispatchSourceTimer(timeInterval: 1) {
   print("CZDispatchSourceTimer - ticking .. Thread.current = \(Thread.current)")
 }
 timer.resume()
 timer.suspend()
 ```
 
 https://gist.github.com/danielgalasko/1da90276f23ea24cb3467c33d2c05768
 https://www.semicolonworld.com/question/76828/dispatchsourcetimer-and-swift-3-0
 */
public class CZDispatchSourceTimer: NSObject {
  public typealias Tick = () -> Void
  
  private enum State {
    case initialized
    case suspended
    case resumed
  }
  let queue: DispatchQueue
  let timer: DispatchSourceTimer
  let timeInterval: Int
  var tickClosure: DispatchSourceProtocol.DispatchSourceHandler?

  private var state: State = .initialized
  
  public init(timeInterval: Int,
              tickClosure: DispatchSourceProtocol.DispatchSourceHandler? = nil) {
    self.timeInterval = timeInterval
    self.tickClosure = tickClosure
    
    // Serial queue - no guarantee executes on the same thread.
    queue = DispatchQueue(label: "com.CZDispatchSourceTimer")
    
    timer = DispatchSource.makeTimerSource(
      flags: DispatchSource.TimerFlags(rawValue: UInt(0)),
      queue: queue)
    
    super.init()
  }
  
  deinit {
    timer.setEventHandler {}
    timer.cancel()
    
    // If the timer is suspended, calling cancel without resuming
    // triggers a crash. This is documented here https://forums.developer.apple.com/thread/15902
    resume()
  }
  
  private func start() {
    assert(tickClosure != nil, "tickClosure shouldn't be nil.")
    
    timer.schedule(deadline: DispatchTime.now(),
                   repeating: .seconds(timeInterval),
                   leeway: .seconds(timeInterval)
    )
    timer.setEventHandler(handler: tickClosure)
    timer.resume()
  }
  
  public func resume() {
    if state == .initialized {
      start()
      return
    } else if state == .resumed {
      return
    }
    
    state = .resumed
    timer.resume()
  }
  
  public func suspend() {
    if state == .suspended {
      return
    }
    state = .suspended
    timer.suspend()
  }
}

