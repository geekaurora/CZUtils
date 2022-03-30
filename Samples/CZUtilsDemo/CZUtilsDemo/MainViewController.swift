import UIKit
import CZUtils

class MainViewController: UIViewController {
  private static let queue = DispatchQueue(label: "LensDiscoveryAssetsProvider")

  @objc public static var animationJSONPath: String? = ""

  private enum AssetStatus {
    case unknown
    case available
    case unavailable
  }

  private static var assetStatus: AssetStatus = .unknown

  @objc public static func checkAssetAvailability(completion: @escaping (Bool) -> Void) {
    queue.async {
      let isAssetAvailable = Self.isAssetAvailable
      DispatchQueue.main.async {
        completion(isAssetAvailable)
      }
    }
  }

  private static var isAssetAvailable: Bool {
    switch assetStatus {
    case .available:
      return true
    case .unavailable:
      return false
    case .unknown:
      guard let path = animationJSONPath else {
        return false
      }
      let result = FileManager.default.isReadableFile(atPath: path)
      assetStatus = result ? .available : .unavailable
      return result
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

