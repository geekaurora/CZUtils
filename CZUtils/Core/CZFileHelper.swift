//
//  CZFileHelper.swift
//
//  Created by Cheng Zhang on 9/23/17.
//  Copyright © 2017 Cheng Zhang. All rights reserved.
//

import UIKit

/// Helper class for file related methods 
@objc open class CZFileHelper: NSObject {
   public static func getFileSize(_ filePath: String?) -> Int? {
        guard let filePath = filePath else {return nil}
        do {
            let attrs = try FileManager.default.attributesOfItem(atPath: filePath)
            let size =  attrs[.size] as? Int
            return size
        } catch {
            print("Failed to get file size of \(filePath). Error - \(error.localizedDescription)")
        }
        return nil
    }
    
    @objc public static var documentDirectory: String {
        return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
    }
}
