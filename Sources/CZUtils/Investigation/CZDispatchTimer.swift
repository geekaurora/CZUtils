import Foundation

/**
 Timer implemented with DispatchSourceTimer.
 */
class CZDispatchTimer: NSObject {
  let queue: DispatchQueue
  let timer: DispatchSourceTimer
  
  override init() {
    queue = DispatchQueue(label: "com.firm.app.timer",
                              attributes: DispatchQueue.Attributes.concurrent)
    timer = DispatchSource.makeTimerSource(flags: DispatchSource.TimerFlags(rawValue: UInt(0)),
                                               queue: queue)
    super.init()
  }
  
  func start() {
    timer.schedule(deadline: DispatchTime.now(),
                   repeating: .seconds(5),
                            leeway: .seconds(1)
    )
    
    timer.setEventHandler(handler: {
      //a bunch of code here
    })
    
    timer.resume()
  }
}

