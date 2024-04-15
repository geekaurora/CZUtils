import UIKit

#if DEBUG

/// Helper methods for debugging Auto Layout.
@objc
extension UIView {
  /// Prints the layout reports for the view and its subviews.
  ///
  /// - Note: If a view's `hasAmbiguousLayout` is true, you may:
  /// 1) In the cosole, set a breakpoint and `po [view _autolayoutTrace]` to get  more details.
  /// 2) In your code, call `view.exerciseAmbiguityInLayout()` to toggle between different UI solutions.
  ///
  /// ### Usage
  ///
  /// If your app supports multiple scenes,
  /// ```
  /// UIApplication.shared.windows.last?.rootViewController?.view.cz_printLayoutReports()
  /// ```
  ///
  /// Otherwise,
  /// ```
  /// UIApplication.shared.keyWindow?.rootViewController?.view.cz_printLayoutReports()
  /// ```
  @objc
  public func cz_printLayoutReports() {
    print("\n=============================\n\(#function)\n=============================")

    cz_printLayoutReports(level: 0)
  }

  /// Prints the layout reports for the view and its subviews with `allowRecursion`.
  /// - Note: The method doesn't support ObjC.
  public func cz_printLayoutReports(level: Int) {
    print(cz_layoutDescription(level: level).prefixingIndents(count: level) + "\n")

    for clazz in UIView.skippableClasses where self.isKind(of: clazz) {
      return
    }

    for view in subviews {
      view.cz_printLayoutReports(level: level + 1)
    }
  }

  /// Returns the layout report for the view.
  @objc
  public func cz_layoutDescription(level: Int) -> String {
    var description = "[L\(level)] <\(Unmanaged.passUnretained(self).toOpaque())> \(type(of: self)) : \(type(of: self).superclass()!)"

    if translatesAutoresizingMaskIntoConstraints {
      description += " [Autosizes]"
    }

    // Check whether the view has ambiguous layouts.
    // Note: If `hasAmbiguousLayout` is true, UIKit will display an warning of
    // "View has an ambiguous layout" automatically.
    if hasAmbiguousLayout {
      description += "  <<<<<<<<<<<<<<<< [AMBIGUOUS LAYOUT!]"
    }

    description += "\nContent size...\(sizeString(intrinsicContentSize))"

    if intrinsicContentSize.width > 0 || intrinsicContentSize.height > 0 {
      description += " [Content Mode: \(UIView.nameForContentMode(contentMode))]"
    }

    description += "\nHugging........[H \(hugValueH)] [V \(hugValueV)]\n"
    description += "Resistance.....[H \(resistValueH)] [V \(resistValueV))]\n"
    description += "Constraints....\(cz_groupedConstraints.count)\n"

    for i in 0..<cz_groupedConstraints.count {
      let constraint = cz_groupedConstraints[i]
      description += String(format: "%2d. ", i)
      description += "@\(constraint.priority) \(constraint) \n"
    }

    return description
  }

  /// Returns all constraints that refer to the view.
  @objc
  public var cz_referencingConstraints: Set<NSLayoutConstraint> {
    let referencingConstraints = Set(cz_groupedConstraints.filter { $0.refersToView(self) })
    return referencingConstraints.union(referencingConstraintsInSuperviews)
  }

  // MARK: - Private methods

  /// Returns the grouped constraints on: 1) horizontal and 2) vertical directions.
  fileprivate var cz_groupedConstraints: [NSLayoutConstraint] {
    let groupedConstraints = constraintsAffectingLayout(for: .horizontal) + constraintsAffectingLayout(for: .vertical)
    let remainingConstraints = constraints.filter { !groupedConstraints.contains($0) }

    assert(remainingConstraints.isEmpty, "remainingConstraints should be empty.")
    return groupedConstraints + remainingConstraints
  }

  fileprivate var referencingConstraintsInSuperviews: Set<NSLayoutConstraint> {
    var results = Set<NSLayoutConstraint>()

    var currentView: UIView? = self
    while let view = currentView?.superview {
      let referencingConstraints = Set(view.cz_groupedConstraints.filter { $0.refersToView(self) })
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

fileprivate extension CGFloat {
  var truncatingDecimals: String {
    return String(format: "%.0f", self)
  }
}

extension String {
  /// Prefixes `count` white spaces to the string on each line.
  fileprivate func prefixingIndents(count: Int) -> String {
    let leadingWhitespaces = (0..<count).reduce("", { (str, _) in
      str + " "
    })
    return self
      .split(separator: "\n")
      .map { leadingWhitespaces + $0 }
      .joined(separator: "\n")
  }
}

fileprivate func sizeString(_ size: CGSize) -> String {
  return "(\(size.width.truncatingDecimals), \(size.height.truncatingDecimals))"
}

#endif
