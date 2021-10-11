import UIKit
import CZUtils

class MainViewController: UIViewController {
  var timer: Timer?
  var weakTimer: CZWeakTimer?
  
//  let timer = CZDispatchSourceTimer(timeInterval: 1) {
//    print("CZDispatchSourceTimer - ticking .. Thread.current = \(Thread.current)")
//  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    // timer.start()
    
//    Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
//      dbgPrint("tick ..")
//    }
    
    weakTimer = CZWeakTimer.scheduledTimer(
      timeInterval: 1,
      target: self,
      selector: #selector(tick(_:)),
      userInfo: nil,
      repeats: true)
    
//    timer = Timer.scheduledTimer(
//      timeInterval: 1,
//      target: self,
//      selector: #selector(tick(_:)),
//      userInfo: nil,
//      repeats: true)
  }
  
  @objc
  func tick(_ timer: Timer) {
    dbgPrint("tick ..")
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentFPSLabelDemoController()
  }
  
  func presentFPSLabelDemoController() {
    let fpsLabelDemoController = FPSLabelDemoController()
    present(fpsLabelDemoController, animated: true, completion: nil)
  }
}

