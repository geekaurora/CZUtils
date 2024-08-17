import UIKit

/**
 Container controller that maintains an underlying StackView for the arranged subviews.
 
 ## Usage
   1. Subclass CZStackViewController.
  2. Override `setupViews()` for customization: add arranged subviews etc.
 */
open class CZStackViewController: UIViewController {
  public private(set) var stackView: UIStackView!
  
  public override init(nibName nibNameOrNil: String? = nil,
                       bundle nibBundleOrNil: Bundle? = nil) {
    super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
  }
  
  required public init?(coder: NSCoder) {
    super.init(coder: coder)
  }
  
  open override func viewDidLoad() {
    super.viewDidLoad()
    setupViews()
  }

  /// Set up subviews - you may override it for customization.
  open func setupViews() {
    view.translatesAutoresizingMaskIntoConstraints = false

    // Set up stackView.
    stackView = UIStackView()
    stackView.translatesAutoresizingMaskIntoConstraints = false
    stackView.axis = .vertical
    view.addSubview(stackView)
    NSLayoutConstraint.activate([
      // Ensure the heights of arrangedViews are correct in case any intrinsic height of them is 0.
      stackView.align(to: view.safeAreaLayoutGuide)
    ])
  }
}
