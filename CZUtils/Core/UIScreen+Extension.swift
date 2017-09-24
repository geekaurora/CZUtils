//
//  UIScreen+Extension.swift
//
//  Created by Cheng Zhang on 7/22/17.
//  Copyright © 2017 Groupon Inc. All rights reserved.
//

import UIKit

public extension UIScreen {
    public static var currSize: CGSize {
        return main.bounds.size
    }

    public static var currWidth: CGFloat {
        return currSize.width
    }

    public static var currHeight: CGFloat {
        return currSize.height
    }

}
