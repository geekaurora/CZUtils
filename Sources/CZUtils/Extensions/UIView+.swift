//
//  UIView+Extension.swift
//
//  Created by Cheng Zhang on 1/12/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit

/// Constants for UIView extensions
public enum UIViewConstants {
  public static let fadeInDuration: TimeInterval = 0.4
  public static let fadeInAnimationName = "com.tony.animation.fadein"
}

// MARK: - Auto Layout

@objc public extension UIView {
  /// Overlap on `superviewIn`, added to `superviewIn` if invoker has no superview.
  func overlayOnSuperview(_ superviewIn: UIView? = nil, insets: NSDirectionalEdgeInsets = .zero) {
    if superview == nil {
      superviewIn?.addSubview(self)
    }
    guard let superview = self.superview else {return}
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: superview.leadingAnchor, constant: insets.leading),
      trailingAnchor.constraint(equalTo: superview.trailingAnchor, constant: -insets.trailing),
      topAnchor.constraint(equalTo: superview.topAnchor, constant: insets.top),
      bottomAnchor.constraint(equalTo: superview.bottomAnchor, constant: -insets.bottom)
    ]
    )
  }
  
  func overlayOnSuperview(_ superviewIn: UIView?) {
    overlayOnSuperview(superviewIn, insets: .zero)
  }
  
  /// Overlap on super `controller` after being added to super `controller` view automatically.
  func overlayOnSuperViewController(_ controller: UIViewController, insets: NSDirectionalEdgeInsets = .zero) {
    guard let containerView = controller.view else {
      assertionFailure("\(#function): superview is nil.")
      return
    }
    if superview == nil {
      containerView.addSubview(self)
    }
    translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      leadingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.leadingAnchor, constant: insets.leading),
      trailingAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.trailingAnchor, constant: -insets.trailing),
      topAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.topAnchor, constant: insets.top),
      bottomAnchor.constraint(equalTo: containerView.safeAreaLayoutGuide.bottomAnchor, constant: -insets.bottom)
    ])
  }
  
  func overlayOnSuperViewController(_ controller: UIViewController) {
    overlayOnSuperViewController(controller, insets: .zero)
  }
}


// MARK: - Corner/Border
@objc public extension UIView {
  
  func roundToCircle() {
    let width = self.bounds.size.width
    layer.cornerRadius = width / 2
    layer.masksToBounds = true
  }
  
  func roundCorner(_ cornerRadius: CGFloat = 2,
                   boarderWidth: CGFloat = 0,
                   boarderColor: UIColor = .clear,
                   shadowColor: UIColor = .clear,
                   shadowOffset: CGSize = .zero,
                   shadowRadius: CGFloat = 2,
                   shadowOpacity: Float = 1) {
    layer.masksToBounds = true
    layer.cornerRadius = cornerRadius
    layer.borderColor = boarderColor.cgColor
    layer.borderWidth = boarderWidth
    
    layer.shadowColor = shadowColor.cgColor
    layer.shadowOffset = shadowOffset
    layer.shadowRadius = shadowRadius
  }
  
}

// MARK: - Animations

@objc public extension UIView {
  func fadeIn(animationName: String = UIViewConstants.fadeInAnimationName,
              duration: TimeInterval = UIViewConstants.fadeInDuration) {
    let transition = CATransition()
    transition.duration = duration
    transition.timingFunction = CAMediaTimingFunction(name: CAMediaTimingFunctionName.easeInEaseOut)
    transition.type = CATransitionType.fade
    layer.add(transition, forKey: animationName)
  }
}

// MARK: - Load Nib

@objc public extension UIView {
  /// Load form nib file and overlay the contentView on superView
  @discardableResult
  func loadAndOverlay(on superView: UIView, xibName: String? = nil) -> UIView {
    // Unarchive and own properties of nibFile.
    // Note: During runtime, loadFromNib traverses from leaf(subestClass) to root(superestClass) to find appropriate nib file, so we can put loadFromNib in superClass, instead subclasses.
    // It climbs via the path "SubClassName.xib" => "UIView.xib" => "UIResponder.xib" => "NSObject.xib" to get the appropriate archived nib file.
    // This is also the mechanism how iOS decides which class's function to invoke in class inheritation tree during runtime, it attempts to objc_msgSend from leaf(subestClass) to root(superestClass) until it gets a matcher or reaches the root of the class inheritation tree which is NSObject class.
    // Load the first view in views array unarchieved from nib
    guard let nibContentView = loadFromNibFile(xibName: xibName)?.first else {
      fatalError("Failed to load nibContentView for class `\(object_getClass(self)!)`: please refer nibContentView outlet to class `\(object_getClass(self)!)` in nib file.")
    }
    // Add and overlap nibContentView on self
    superView.addSubview(nibContentView)
    nibContentView.translatesAutoresizingMaskIntoConstraints = false
    nibContentView.overlayOnSuperview()
    return nibContentView
  }
  
  /// Unarchive and own properties of nibFile
  ///
  /// - Params:
  ///   - xibName : xib filename. `nil` by default
  ///   - bundle  : bundle to load nib file.
  /// - Returns   : views array unarchived from nib file
  @discardableResult
  func loadFromNibFile(xibName: String? = nil, bundle: Bundle = Bundle.main) -> [UIView]? {
    var views: [UIView]?
    // Class of the current object
    var classRef: AnyClass? = object_getClass(self)
    while let currClassRef = classRef, views == nil {
      // Get nibName from className of current level
      var nibName = xibName ?? NSStringFromClass(currClassRef)
      // Swift class name prefix with module name, so we need to extract the last part of seperate components for Swift class
      nibName = nibName.components(separatedBy: ".").last!
      // Unarchive views from nibFile
      views = bundle.loadNibNamed(nibName, owner: self, options: nil) as? [UIView]
      // Climb up higher level through class inheritance tree
      classRef = currClassRef.superclass()
    }
    assert(views != nil, "Fail to loadFromNibFile for class `\(object_getClass(self)!)`.\n")
    return views
  }
}
