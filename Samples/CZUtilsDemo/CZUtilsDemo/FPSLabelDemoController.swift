import UIKit
import CZUtils

class FPSLabelDemoController: UIViewController {
  var count = 0
  
  override func viewDidLoad() {
    super.viewDidLoad()
   // view.backgroundColor = .white

    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
      self.testMainThreadDelay()
    }
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

