import UIKit
import CZUtils

class FPSLabelDemoController: UIViewController {

  private lazy var fpsLabel: CZFPSLabel = {
    let fpsLabel = CZFPSLabel()
    return fpsLabel
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    initSubviews()
    testMainThreadDelay()
  }
  
  func initSubviews() {
    fpsLabel.display(on: view)    
  }
  
  func testMainThreadDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      sleep(200)
      self?.testMainThreadDelay()
    }
  }
}

