import UIKit

public extension UIApplication {
  /// Returns top most view controller on `inputController`.
  /// Note: `inputController` defaults to keyWindow.rootViewControlle if input is nil
  ///
  /// - Parameter inputController: The  view controller which contains top most controller.
  /// - Returns: top most view controller on `inputController`.
  func topMostViewController(on inputController: UIViewController? = nil) -> UIViewController? {
    let controller = inputController ?? self.keyWindow?.rootViewController
    
    if let topChildController = controller?.children.last {
      return topMostViewController(on: topChildController)
    }
    if let navigationController = controller as? UINavigationController {
      return topMostViewController(on: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topMostViewController(on: selected)
      }
    }
    if let presented = controller?.presentedViewController {
      return topMostViewController(on: presented)
    }
    return controller
  }
}


