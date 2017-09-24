//
//  UIScreen+Extension.swift
//  CZFacebook
//
//  Created by Cheng Zhang on 7/22/17.
//  Copyright © 2017 Groupon Inc. All rights reserved.
//

import UIKit

extension UIScreen {
    static var currSize: CGSize {
        return main.bounds.size
    }

    static var currWidth: CGFloat {
        return currSize.width
    }

    static var currHeight: CGFloat {
        return currSize.height
    }

}
