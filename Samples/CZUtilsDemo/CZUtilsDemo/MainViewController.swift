import UIKit
import CZUtils

class MainViewController: UIViewController {
  
  let timer = CZDispatchSourceTimer(timeInterval: 1) {
    print("CZDispatchSourceTimer - ticking .. Thread.current = \(Thread.current)")
  }
  
  override func viewDidLoad() {
    super.viewDidLoad()
    timer.start()
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

