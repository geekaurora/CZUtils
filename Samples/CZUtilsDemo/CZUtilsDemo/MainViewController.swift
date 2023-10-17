import UIKit
import CZUtils

class MainViewController: UIViewController {
  private var count = 0

  override func viewDidLoad() {
    super.viewDidLoad()
    CADisplayLinkMonitor.shared.start()
  }

  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    self.testDispatchAsync()
  }

  func testDispatchAsync() {
#if true
    // 1. Call dispatch_async sequentially: will all be executed in the next runloop cycle.
    for _ in 0..<10 {
      DispatchQueue.main.async {
        usleep(200 * 1000)
      }
    }
#else
    // 2. Call dispatch_async nestedly: correct - will be executed in separate runloop cycles.
    guard count < 10 else {
      return
    }
    DispatchQueue.main.async {
      self.count += 1
      usleep(200 * 1000)
      self.testDispatchAsync()
    }
#endif
  }
}

