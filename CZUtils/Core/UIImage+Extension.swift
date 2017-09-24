//
//  UIImage+Extensino.swift
//  CZInstagram
//
//  Created by Administrator on 15/09/2017.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit
import ImageIO

extension UIImage {

    @objc(cropToRect:)
    func crop(toRect rect: CGRect) -> UIImage {
        let croppedCGImage = self.cgImage!.cropping(to: rect)!
        let res = UIImage(cgImage: croppedCGImage)
        return res
    }
    
    @objc(cropToSize:)
    func crop(toSize size: CGSize) -> UIImage {
        var size = size
        let ratio = size.height / size.width
        if  size.width <  size.height {
            size.width = self.size.width * self.scale
            size.height = size.width * ratio
        } else {
            size.height = self.size.height * self.scale
            size.width = size.width * ratio
        }
        let rect = CGRect(origin: CGPoint(x: (self.size.width * self.scale - size.width) / 2,
                                          y: (self.size.height * self.scale - size.height) / 2),
                          size: size)
        return crop(toRect: rect)
    }

    // height / width
    @objc(cropToRatio:)
    func crop(toRatio ratio: CGFloat) -> UIImage {
        var size: CGSize = self.size
        if  ratio < 1 {
            size.width = self.size.width * self.scale
            size.height = size.width * ratio
        } else {
            size.height = self.size.height * self.scale
            size.width = size.height / ratio
        }
        let rect = CGRect(origin: CGPoint(x: (self.size.width * self.scale - size.width) / 2,
                                          y: (self.size.height * self.scale - size.height) / 2),
                          size: size)
        return crop(toRect: rect)
    }

    /*
    - (UIImage *)cropToRect:(CGRect)rect {
    CGImageRef subImageRef = CGImageCreateWithImageInRect(self.target.CGImage, rect);
    CGRect subBounds = CGRectMake(0, 0, CGImageGetWidth(subImageRef), CGImageGetHeight(subImageRef));
    
    UIGraphicsBeginImageContext(subBounds.size);
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextDrawImage(context, subBounds, subImageRef);
    
    UIImage *subImage = [UIImage imageWithCGImage:subImageRef];
    CGImageRelease(subImageRef);
    UIGraphicsEndImageContext();
    return subImage;
    }
*/
}
