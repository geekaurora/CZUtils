import UIKit
import CZUtils

class MainViewController: UIViewController {
  private static let queue = DispatchQueue(
      label: "LensDiscoveryAssetsProvider", attributes: [])

  @objc public static var animationJSONPath: String? = ""

  private enum AssetStatus {
    case unknown
    case available
    case unavailable
  }

  private static var assetStatus: AssetStatus = .unknown

  @objc public static func checkAssetAvailability(completion: @escaping (Bool) -> Void) {
    queue.async {
      switch assetStatus {
      case .available:
        asyncOnMainThread(true, completion)

      case .unavailable:
        asyncOnMainThread(false, completion)

      case .unknown:
        guard let path = animationJSONPath else {
          asyncOnMainThread(false, completion)
          return
        }
        let result = FileManager.default.isReadableFile(atPath: path)
        assetStatus = result ? .available : .unavailable
        asyncOnMainThread(result, completion)
      }
    }
  }

  /// Call `completion` on the main thread asynchronously with the `result`.
  private static func asyncOnMainThread(_ result: Bool, _ completion: @escaping (Bool) -> Void) {
    DispatchQueue.main.async {
      completion(result)
    }
  }

  override func viewDidLoad() {
    super.viewDidLoad()
  }
  
  override func viewDidAppear(_ animated: Bool) {
    super.viewDidAppear(animated)
    presentFPSLabelDemoController()
  }
  
  func presentFPSLabelDemoController() {
    let fpsLabelDemoController = FPSLabelDemoController()
    present(fpsLabelDemoController, animated: true, completion: nil)
  }
}

