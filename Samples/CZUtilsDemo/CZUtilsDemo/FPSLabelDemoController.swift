import UIKit
import CZUtils

class FPSLabelDemoController: UIViewController {
  var count = 0
  
  private lazy var fpsLabel: CZFPSLabel = {
    let fpsLabel = CZFPSLabel()
    return fpsLabel
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.backgroundColor = .white
    
    initSubviews()
    
    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.testMainThreadDelay()
    }
  }
  
  func initSubviews() {
    fpsLabel.display(on: view)
  }
  
  func testMainThreadDelay() {
    for _ in 0..<10 {
      DispatchQueue.main.async {
        usleep(200 * 1000)
      }
    }
    
//    if count < 10 {
//      count += 1
//      // Sleep 200 ms.
//      usleep(200 * 1000)
//
//      DispatchQueue.main.async {
//        self.testMainThreadDelay()
//      }
//    }
  }
}

