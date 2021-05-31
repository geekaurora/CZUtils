import UIKit

class ViewController: UIViewController {
  private lazy var gapTaskSchedulerTester: GapTaskSchedulerTester = {
    return GapTaskSchedulerTester()
  }()
  
  override func viewDidLoad() {
    super.viewDidLoad()
    testGapTaskSchedulerTester()
  }
  
  func testGapTaskSchedulerTester() {
    gapTaskSchedulerTester.testTasksInComplexCombinedGaps()
  }
}

