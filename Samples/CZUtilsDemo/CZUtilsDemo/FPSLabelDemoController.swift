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
    DispatchQueue.main.asyncAfter(deadline: .now() + 3) {      
      for _ in 0..<10 {
        DispatchQueue.main.async {
          usleep(200 * 1000)
        }
      }
    }
    
//    DispatchQueue.main.asyncAfter(deadline: .now() + 3) { [weak self] in
//      // Sleep 200 ms.
//      usleep(200 * 1000)
//      self?.testMainThreadDelay()
//    }
  }
}

