import UIKit
import CZUtils

class MainViewController: UIViewController {
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentFPSLabelDemoController()
  }
  
  func presentFPSLabelDemoController() {
    let fpsLabelDemoController = FPSLabelDemoController()
    present(fpsLabelDemoController, animated: true, completion: nil)
  }
}

