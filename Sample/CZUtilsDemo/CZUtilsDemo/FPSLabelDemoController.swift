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
    view.addSubview(fpsLabel)
    NSLayoutConstraint.activate([
      fpsLabel.alignLeading(to: view.safeAreaLayoutGuide, constant: 5),
      fpsLabel.alignBottom(to: view.safeAreaLayoutGuide, constant: 5)
    ])
  }
  
  func testMainThreadDelay() {
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
      sleep(200)
      self?.testMainThreadDelay()
    }
  }
}

