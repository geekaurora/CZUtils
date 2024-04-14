import UIKit

#if DEBUG

/// Helper methods for debugging Auto Layout.
@objc
extension UIView {
  /// Prints the layout reports for the view and its subviews.
  @objc
  public func cz_printLayoutReports() {
    print(cz_layoutDescription)

    for clazz in UIView.skippableClasses where self.isKind(of: clazz) {
      return
    }

    for view in subviews {
      view.cz_printLayoutReports()
    }
  }

  /// Returns the layout report for the view.
  @objc
  public var cz_layoutDescription: String {
    var description = "<\(Unmanaged.passUnretained(self).toOpaque())> \(type(of: self)) : \(type(of: self).superclass()!)"

    if translatesAutoresizingMaskIntoConstraints {
      description += " [Autosizes]"
    }

    // Check whether the view has ambiguous layouts.
    if hasAmbiguousLayout {
      description += "\n\n----\n[Caution!] FOUND Ambiguous Layouts!"
    }

    description += "\nContent size...\(sizeString(intrinsicContentSize))"

    if intrinsicContentSize.width > 0 || intrinsicContentSize.height > 0 {
      description += " [Content Mode: \(UIView.nameForContentMode(contentMode))]"
    }

    description += "\nHugging........[H \(hugValueH)] [V \(hugValueV)]\n"
    description += "Resistance.....[H \(resistValueH)] [V \(resistValueV))]\n"
    description += "Constraints....\(constraints.count)\n"

    for i in 0..<constraints.count {
      let constraint = constraints[i]
      description += String(format: "%2d. ", i)
      description += "@\(constraint.priority) \(constraint) \n"
    }

    return description
  }

  /// Returns all constraints that refer to the view.
  @objc
  public var cz_referencingConstraints: Set<NSLayoutConstraint> {
    let referencingConstraints = Set(constraints.filter { $0.refersToView(self) })
    return referencingConstraints.union(referencingConstraintsInSuperviews)
  }

  // MARK: - Private methods

  fileprivate var referencingConstraintsInSuperviews: Set<NSLayoutConstraint> {
    var results = Set<NSLayoutConstraint>()

    var currentView: UIView? = self
    while let view = currentView?.superview {
      let referencingConstraints = Set(view.constraints.filter { $0.refersToView(self) })
      results = results.union(referencingConstraints)

      currentView = view
    }
    return results
  }


  fileprivate var hugValueH: Float {
    return Float(contentHuggingPriority(for: .horizontal).rawValue)
  }

  fileprivate var hugValueV: Float {
    return Float(contentHuggingPriority(for: .vertical).rawValue)
  }

  fileprivate var resistValueH: Float {
    return Float(contentCompressionResistancePriority(for: .horizontal).rawValue)
  }

  fileprivate var resistValueV: Float {
    return Float(contentCompressionResistancePriority(for: .vertical).rawValue)
  }

  fileprivate static func nameForContentMode(_ contentMode: UIView.ContentMode) -> String {
    switch contentMode {
    case .scaleToFill:
      return "ScaleToFill"
    case .scaleAspectFit:
      return "ScaleAspectFit"
    case .scaleAspectFill:
      return "ScaleAspectFill"
    case .redraw:
      return "Redraw"
    case .center:
      return "Center"
    case .top:
      return "Top"
    case .bottom:
      return "Bottom"
    case .left:
      return "Left"
    case .right:
      return "Right"
    case .topLeft:
      return "TopLeft"
    case .topRight:
      return "TopRight"
    case .bottomLeft:
      return "BottomLeft"
    case .bottomRight:
      return "BottomRight"
    default:
      return "Unknown"
    }
  }

  fileprivate static var skippableClasses: [UIView.Type] {
    return [UIButton.self, UILabel.self, UISwitch.self, UIStepper.self, UITextField.self, UIScrollView.self, UIActivityIndicatorView.self, UIAlertView.self, UIPickerView.self, UIProgressView.self, UIToolbar.self, UINavigationBar.self, UISearchBar.self, UITabBar.self]
  }
}

fileprivate extension NSLayoutConstraint {
  func refersToView(_ view: UIView) -> Bool {
    return firstItem === view || secondItem === view
  }
}

fileprivate func sizeString(_ size: CGSize) -> String {
  return "(\(size.width), \(size.height))"
}

#endif
