import UIKit
import CZUtils

class FPSLabelDemoController: UIViewController {

  private lazy var fpsLabel: CZFPSLabel = {
    let fpsLabel = CZFPSLabel(frame: CGRect(x: 40, y: 40, width: 100, height: 100))
    return fpsLabel
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    initSubviews()
    testMainThreadDelay()
  }
  
  func initSubviews() {
    // view.addSubview(fpsLabel)
    fpsLabel.overlayOnSuperViewController(self)
  }
  
  func testMainThreadDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      sleep(200)
      self?.testMainThreadDelay()
    }
  }
}

