import UIKit
import CZUtils

class FPSLabelDemoController: UIViewController {

  private lazy var fpsLabel: CZFPSLabel = {
    // let fpsLabel = CZFPSLabel(frame: CGRect(x: 40, y: 40, width: 100, height: 100))
    let fpsLabel = CZFPSLabel(frame: CGRect(x: 40, y: 40, width: 0, height: 0))
    return fpsLabel
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    initSubviews()
    testMainThreadDelay()
  }
  
  func initSubviews() {
    view.addSubview(fpsLabel)
    // fpsLabel.overlayOnSuperViewController(self)
  }
  
  func testMainThreadDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      sleep(200)
      self?.testMainThreadDelay()
    }
  }
}

