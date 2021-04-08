//
//  CZFileHelper.swift
//
//  Created by Cheng Zhang on 1/13/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation

/// Helper class for file related methods 
@objc open class CZFileHelper: NSObject {
  @objc public static var documentDirectory: String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
  }
  
  public static func getFileSize(_ filePath: String?) -> Int? {
    guard let filePath = filePath else { return nil }
    do {
      let attrs = try FileManager.default.attributesOfItem(atPath: filePath)
      let size =  attrs[.size] as? Int
      return size
    } catch {
      dbgPrint("Failed to get file size of \(filePath). Error - \(error.localizedDescription)")
    }
    return nil
  }
  
  /**
    Returns whether the file exists.
   */
  public static func fileExists(url: URL?) -> Bool {
    guard let url = url else { return false }
    return FileManager.default.fileExists(atPath: url.path)
  }
  
  /**
    Remove local file at `url`.       
   */
  public static func removeFile(_ url: URL?) {
    guard let url = url,
          fileExists(url:url) else {
      return
    }
    
    do {
      try FileManager.default.removeItem(at: url)
    } catch let error as NSError {
      dbgPrint("Failed to remove file - \(url). Error - \(error.localizedDescription)")
    }
  }
}
