//
//  UIViewController+Addtion.swift
//
//  Created by Cheng Zhang on 4/19/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import UIKit

public extension UIViewController {
  /// Stick the intput view's edges to topLayoutGuide, bottomLayoutGuide, leading, trailing
  func overlapSubViewOnSelf(_ subview: UIView) {
    subview.translatesAutoresizingMaskIntoConstraints = false
    NSLayoutConstraint.activate([
      subview.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
      subview.leadingAnchor.constraint(equalTo: view.leadingAnchor),
      subview.trailingAnchor.constraint(equalTo: view.trailingAnchor),
      subview.bottomAnchor.constraint(equalTo: view.bottomAnchor)
    ])
  }
  
  /// Returns top most ViewController on the current keyWindow.
  class func topMost(on controller: UIViewController? = UIApplication.shared.keyWindow?.rootViewController) -> UIViewController? {
    if let navigationController = controller as? UINavigationController {
      return topMost(on: navigationController.visibleViewController)
    }
    if let tabController = controller as? UITabBarController {
      if let selected = tabController.selectedViewController {
        return topMost(on: selected)
      }
    }
    if let presented = controller?.presentedViewController {
      return topMost(on: presented)
    }
    return controller
  }
  
  func showTitleOnNavBar() {
    let internalTitleView: UIView
    if let image = UIImage(named: "InstagramTitle") {
      internalTitleView = UIImageView(image: image)
    } else {
      let titleView = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
      titleView.textAlignment = .center
      titleView.text = "Instagram"
      titleView.font = UIFont(name: "Baskerville-SemiBoldItalic", size: 25)
      titleView.textColor = UIColor(white: 0.22, alpha: 1)
      internalTitleView = titleView
    }
    navigationItem.titleView = internalTitleView
  }
  
  func setTabTitle(_ title: String, at index: Int) {
    guard let tabBarItems = tabBarController?.tabBar.items,
      0..<tabBarItems.count ~= index else { return }
    tabBarItems[index].title = NSLocalizedString(title, comment: "")
  }
}


