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
  
  /**
    Remove local file at `path`.
   */
  public static func removeFile(path: String) {
    let url = URL(fileURLWithPath: path)
    removeFile(url)
  }
  
  /**
    Remove the directory at `path`.
   
   - Parameter createDirectoryAfterDeletion: Indicates whether to create the directory after the deletion.
   */
  public static func removeDirectory(path: String, createDirectoryAfterDeletion: Bool = false) {
    let url = URL(fileURLWithPath: path)
    removeFile(url)
    
    if createDirectoryAfterDeletion {
      createDirectoryIfNeeded(at: path)
    }
  }
  
  /**
   Indicates whether `path` is a directory.
   */
  public static func isDirectory(path: String) -> Bool {
    var isDirectoryValue: ObjCBool = false
    guard FileManager.default.fileExists(atPath: path, isDirectory: &isDirectoryValue) else {
      assertionFailure("Failed to execute `FileManager.default.fileExists()`.")
      return false
    }
    return isDirectoryValue.boolValue
  }
  
  /**
   Create the directory if it doesn't exist.
   */
  public static func createDirectoryIfNeeded(at path: String) {
    if !FileManager.default.fileExists(atPath: path) {
      do {
        try FileManager.default.createDirectory(atPath: path, withIntermediateDirectories: true, attributes: nil)
      } catch {
        assertionFailure("Failed to create the directory! Error - \(error.localizedDescription); path - \(path)")
      }
    }
  }
  
  /**
    Append `string` to the file.
   */
  public static func appendStringToFile(url: URL?, string: String) {
    guard let url = url else { return }
    
    // Read file.
    var existingContent = ""
    if fileExists(url:url) {
      do {
        existingContent = try String(contentsOf: url)
      } catch {
        dbgPrint("Failed to read file - \(url). Error - \(error.localizedDescription)")
      }
    }
    
    // Write file.
    existingContent += "\n" + string
    do {
      try existingContent.write(to: url, atomically: true, encoding: .utf8)
    } catch {
      dbgPrint("Failed to write file - \(url). Error - \(error.localizedDescription)")
    }
  }  
  
}
