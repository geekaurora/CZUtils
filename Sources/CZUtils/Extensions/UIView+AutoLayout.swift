import UIKit

/// Convenience methods for AutoLayout, support both UIView/UILayoutGuide as alignment reference,
/// compatible with all existing AutoLayout methods.
///
/// ### Usage
///
///  NSLayoutConstraint.activate([
///    collectionView.align(to: vc.view.safeAreaLayoutGuide),
///    imageView.alignCenter(to: containerView),
///    label.alignHorizontally(to: containerView)
///  ])
public extension NSLayoutConstraint {
  static func activate(_ constraints: [Any]) {
    let constraints = constraints.reduce([]) { (array, item) -> [NSLayoutConstraint] in
      switch item {
      case let item as [NSLayoutConstraint]:
        return array + item
      case let item as NSLayoutConstraint:
        return array + [item]
      default:
        assertionFailure("Invalid input type - \(type(of: item)) \(item)")
        return []
      }
    }
    NSLayoutConstraint.activate(constraints)
  }
}

public extension UIView {
  
  // MARK: - Position / Basics
  
  func alignLeading(to item: GMOAutoLayoutObject?,
                    constant: CGFloat = 0.0,
                    relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .leading,
      to: item,
      attribute: .leading,
      constant: constant,
      relation: relation)
  }
  
  func alignTrailing(to item: GMOAutoLayoutObject?,
                     constant: CGFloat = 0.0,
                     relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .trailing,
      to: item,
      attribute: .trailing,
      constant: constant,
      relation: relation)
  }
  
  func alignTop(to item: GMOAutoLayoutObject?,
                constant: CGFloat = 0.0,
                relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .top,
      to: item,
      attribute: .top,
      constant: constant,
      relation: relation)
  }
  
  func alignBottom(to item: GMOAutoLayoutObject?,
                   constant: CGFloat = 0.0,
                   relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .bottom,
      to: item,
      attribute: .bottom,
      constant: constant,
      relation: relation)
  }
  
  func alignCenterX(to item: GMOAutoLayoutObject?,
                    constant: CGFloat = 0.0,
                    relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .centerX,
      to: item,
      attribute: .centerX,
      constant: constant,
      relation: relation)
    
  }
  
  func alignCenterY(to item: GMOAutoLayoutObject?,
                    constant: CGFloat = 0.0,
                    relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .centerY,
      to: item,
      attribute: .centerY,
      constant: constant,
      relation: relation)
    
  }
  
  func alignCenter(to item: GMOAutoLayoutObject?,
                   constant: CGPoint = .zero,
                   relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
    return [
      alignCenterX(
        to: item,
        constant: constant.x,
        relation: relation),
      alignCenterY(
        to: item,
        constant: constant.y,
        relation: relation)
    ]
  }
  
  // MARK: - Position / Combinations
  
  func alignLeadingToTrailing(of item: GMOAutoLayoutObject?,
                              constant: CGFloat = 0.0,
                              relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .leading,
      to: item,
      attribute: .trailing,
      constant: constant,
      relation: relation)
  }
  
  func alignTrailingToLeading(of item: GMOAutoLayoutObject?,
                              constant: CGFloat = 0.0,
                              relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .trailing,
      to: item,
      attribute: .leading,
      constant: constant,
      relation: relation)
  }
  
  func alignTopToBottom(of item: GMOAutoLayoutObject?,
                        constant: CGFloat = 0.0,
                        relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .top,
      to: item,
      attribute: .bottom,
      constant: constant,
      relation: relation)
  }
  
  func alignBottomToTop(of item: GMOAutoLayoutObject?,
                        constant: CGFloat = 0.0,
                        relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .bottom,
      to: item,
      attribute: .top,
      constant: constant,
      relation: relation)
  }
  
  // MARK: - Position / Advanced
  
  func align(to item: GMOAutoLayoutObject?,
             insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
    return [
      alignHorizontally(
        to: item,
        insets: insets),
      alignVertically(
        to: item,
        insets: insets)
      ].flatMap { $0 }
  }
  
  func alignHorizontally(to item: GMOAutoLayoutObject?,
                         insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
    return [
      alignLeading(
        to: item,
        constant: insets.left),
      alignTrailing(
        to: item,
        constant: -insets.right)
    ]
  }
  
  func alignVertically(to item: GMOAutoLayoutObject?,
                       insets: UIEdgeInsets = .zero) -> [NSLayoutConstraint] {
    return [
      alignTop(
        to: item,
        constant: insets.top),
      alignBottom(
        to: item,
        constant: -insets.bottom)
    ]
  }
  
  // MARK: - Sizing
  
  func alignSize(to item: GMOAutoLayoutObject?,
                 constant: CGSize = .zero,
                 relation: NSLayoutConstraint.Relation = .equal,
                 multiplier: CGFloat = 1.0) -> [NSLayoutConstraint] {
    return [
      alignWidth(
        to: item,
        constant: constant.width,
        relation: relation,
        multiplier: multiplier),
      alignHeight(
        to: item,
        constant: constant.height,
        relation: relation,
        multiplier: multiplier)
    ]
  }
  
  func alignWidth(to item: GMOAutoLayoutObject?,
                  constant: CGFloat = 0.0,
                  relation: NSLayoutConstraint.Relation = .equal,
                  multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
    return alignLayout(
      .width,
      to: item,
      attribute: .width,
      constant: constant,
      relation: relation,
      multiplier: multiplier)
  }
  
  func alignHeight(to item: GMOAutoLayoutObject?,
                   constant: CGFloat = 0.0,
                   relation: NSLayoutConstraint.Relation = .equal,
                   multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
    return alignLayout(
      .height,
      to: item,
      attribute: .height,
      constant: constant,
      relation: relation,
      multiplier: multiplier)
  }
  
  // MARK: Constants
  
  func alignSize(to size: CGSize,
                 relation: NSLayoutConstraint.Relation = .equal) -> [NSLayoutConstraint] {
    return [
      alignWidth(
        to: size.width,
        relation: relation),
      alignHeight(
        to: size.height,
        relation: relation)
    ]
  }
  
  func alignWidth(to constant: CGFloat,
                  relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .width,
      to: nil,
      attribute: .notAnAttribute,
      constant: constant,
      relation: relation)
  }
  
  func alignHeight(to constant: CGFloat,
                   relation: NSLayoutConstraint.Relation = .equal) -> NSLayoutConstraint {
    return alignLayout(
      .height,
      to: nil,
      attribute: .notAnAttribute,
      constant: constant,
      relation: relation)
  }
  
  // MARK: - Customization
  
  func alignLayout(_ attr1: NSLayoutConstraint.Attribute,
                   to item: GMOAutoLayoutObject?,
                   attribute attr2: NSLayoutConstraint.Attribute,
                   constant: CGFloat = 0.0,
                   relation: NSLayoutConstraint.Relation = .equal,
                   multiplier: CGFloat = 1.0) -> NSLayoutConstraint {
    if translatesAutoresizingMaskIntoConstraints {
      translatesAutoresizingMaskIntoConstraints = false
    }
    let constraint = NSLayoutConstraint(
      item: self,
      attribute: attr1,
      relatedBy: relation,
      toItem: item,
      attribute: attr2,
      multiplier: multiplier,
      constant: constant)
    return constraint
  }
}

// MARK: - GMOAutoLayoutObject

/// Protocol that identifies Class capable of GMOAutoLayout alignment reference, including UIView, UILayoutGuide.
public protocol GMOAutoLayoutObject: NSObjectProtocol {}
extension UIView: GMOAutoLayoutObject {}
extension UILayoutGuide: GMOAutoLayoutObject {}

// MARK: - GMOConstraintProtocol

/// Protocol that marks Class capable of being activated as item by activate(:), including NSLayoutConstraint, [NSLayoutConstraint].
public protocol GMOConstraintProtocol {}
extension NSLayoutConstraint: GMOConstraintProtocol {}
extension Array: GMOConstraintProtocol where Element: NSLayoutConstraint {}
