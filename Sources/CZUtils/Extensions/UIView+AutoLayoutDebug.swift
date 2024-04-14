import UIKit

#if DEBUG

/// Helper methods for debugging Auto Layout.
@objc
extension UIView {
  /// Prints the layout reports for view and its subviews.
  @objc
  public func cz_printLayoutReports() {
    print(self.cz_viewLayoutDescription)

    for clazz in UIView.skippableClasses() {
      if self.isKind(of: clazz) {
        return
      }
    }

    for view in self.subviews {
      view.cz_printLayoutReports()
    }
  }

  /// Returns details for the view's layout constraints.
  @objc
  public var cz_viewLayoutDescription: String {
    var description = "<\(Unmanaged.passUnretained(self).toOpaque())> \(type(of: self)) : \(type(of: self).superclass()!)"

    if self.translatesAutoresizingMaskIntoConstraints {
      description += " [Autosizes]"
    }

    if self.hasAmbiguousLayout {
      description += "\n\n----\n[Caution!] FOUND Ambiguous Layouts!"
    }

    description += "\nContent size...\(sizeString(self.intrinsicContentSize))"

    if self.intrinsicContentSize.width > 0 || self.intrinsicContentSize.height > 0 {
      description += " [Content Mode: \(UIView.nameForContentMode(self.contentMode))]"
    }

    description += "\nHugging........[H \(hugValueH)] [V \(hugValueV)]\n"
    description += "Resistance.....[H \(resistValueH)] [V \(resistValueV))]\n"
    description += "Constraints....\(self.constraints.count)\n"

    var i = 1
    for constraint in self.constraints {
      description += String(format: "%2d. ", i)
      description += "@\(constraint.priority) "

      description += "\(constraint)"
      description += "\n"
      i += 1
    }

    return description
  }

  /// Returns all constraints that refer to the view.
  func cz_referencingConstraints() -> Set<NSLayoutConstraint> {
    var results = self.referencingConstraintsInSuperviews()

    for constraint in self.constraints {
      if constraint.refersToView(self) {
        results.insert(constraint)
      }
    }

    return results
  }

  // MARK: - Helper methods

  fileprivate func referencingConstraintsInSuperviews() -> Set<NSLayoutConstraint> {
    var results = Set<NSLayoutConstraint>()

    var currentView: UIView? = self
    while let view = currentView?.superview {
      for constraint in view.constraints {
        if constraint.refersToView(self) {
          results.insert(constraint)
        }
      }
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

  fileprivate static func skippableClasses() -> [UIView.Type] {
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
