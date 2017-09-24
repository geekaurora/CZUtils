//
//  UIView+Extension.swift
//  CZInstagram
//
//  Created by Administrator on 04/09/2017.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit

extension UIView {
    func roundToCircleWithFrame() {
        roundToCircle()
        addGrayFrame()
    }
        
    func roundToCircle() {
        let width = self.bounds.size.width
        layer.cornerRadius = width / 2
        layer.masksToBounds = true
    }
    
    func roundCornerWithFrame(cornerRadius: CGFloat = 1, white: CGFloat = CZTheme.greyDividerColor) {
        roundCorner(cornerRadius: cornerRadius)
        addGrayFrame(white)
    }
    
    func roundCorner(cornerRadius: CGFloat = 2) {
        layer.cornerRadius = cornerRadius
        layer.masksToBounds = true
    }
    
    func addGrayFrame(_ white: CGFloat = CZTheme.greyDividerColor) {
        layer.borderWidth = 1
        layer.borderColor = UIColor(white: white, alpha: 1).cgColor
    }
}
