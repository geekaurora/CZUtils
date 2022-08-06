import UIKit

public extension UINavigationController {
  /// Push `viewController` to the stack of UINavigationController with `completion`.
  /// - Parameters:
  ///   - viewController   : The viewController to be pushed.
  ///   - animated                : Whether to animate.
  ///   - completion            : The completion to be called after pushing.
  func pushViewController(_ viewController: UIViewController,
                          animated: Bool,
                          completion: (() -> Void)?) {
    CATransaction.begin()
    CATransaction.setCompletionBlock(completion)
    pushViewController(viewController, animated: animated)
    CATransaction.commit()
  }
}
