import UIKit
import CZUtils

class MainViewController: UIViewController {

  private lazy var fpsLabel: CZFPSLabel = {
    let fpsLabel = CZFPSLabel(frame: CGRect(x: 40, y: 40, width: 100, height: 100))
    return fpsLabel
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    
    initSubviews()
  }
  
  func initSubviews() {
    fpsLabel.overlayOnSuperViewController(self)
  }
}

