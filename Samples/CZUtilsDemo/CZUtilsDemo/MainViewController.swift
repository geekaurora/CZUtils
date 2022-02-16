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
        completion(true)

      case .unavailable:
        completion(false)

      case .unknown:
        guard let path = animationJSONPath else {
          completion(false)
          return
        }
        let result = FileManager.default.isReadableFile(atPath: path)
        queue.sync {
          assetStatus = result ? .available : .unavailable
        }
        completion(result)
      }
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

