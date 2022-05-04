import Foundation

/// Helper class for file related methods 
@objc open class CZFileHelper: NSObject {
  @objc public static var documentDirectory: String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
  }
  
  /**
   [Deprecated] Returns the shared writable folder URL of the simulator. It can be used for sharing data between app and UITest.
  
   - Note: It only works for Simulator.
  
   ### Output
   file:///Users/<userName>/Library/Developer/CoreSimulator/Devices/<GroupId>/data/Library/Shared
   
   - Parameter fileName: file name to be added to the folder.
   - Parameter appGroupName: App group name to group app and UITest bundle on device.
   */
  public static func sharedGroupFolderURL(fileName: String? = nil, appGroupName: String? = nil) -> URL? {
    var sharedFolderURL: URL? = nil
    
    #if !targetEnvironment(simulator)
      // - Note: Doesn't work any more! Got cacheFolderURL correctly, but can’t read / write the folder.
      // Device - AppGroup folder. (needs to config securityApplicationGroupIdentifier)
      // https://developer.apple.com/forums/thread/23418
      guard let appGroupName = appGroupName,
            let appGroupURL = FileManager.default.containerURL(forSecurityApplicationGroupIdentifier: appGroupName) else {
        return nil
      }
    var cacheFolderURL = appGroupURL.appendingPathComponent("Library", isDirectory: true)
    cacheFolderURL = cacheFolderURL.appendingPathComponent("Caches", isDirectory: true)
    let doesCacheFolderExist = CZFileHelper.fileExists(url: cacheFolderURL)
    assert(doesCacheFolderExist, "cacheFolderURL doesn't exist. cacheFolderURL = \(cacheFolderURL)")
    
      sharedFolderURL = cacheFolderURL
    #else
      // Simulator - /Users/<username>/Library/Caches/.
      guard let simulatorSharedDir = ProcessInfo().environment["SIMULATOR_SHARED_RESOURCES_DIRECTORY"] else {
        return nil
      }
      let simulatorHomeDirURL = URL(fileURLWithPath: simulatorSharedDir)
      let cachesDirURL = simulatorHomeDirURL.appendingPathComponent("Library/Caches")
      assert(FileManager.default.isWritableFile(atPath: cachesDirURL.path), "Cannot write to simulator Caches directory - \(cachesDirURL)")
      
      sharedFolderURL = cachesDirURL.appendingPathComponent("Shared")
      createDirectoryIfNeeded(at: sharedFolderURL)
    #endif
    
    if let fileName = fileName {
      return sharedFolderURL?.appendingPathComponent(fileName)
    }
    return sharedFolderURL
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
  public static func removeFile(_ urlIn: URL?) {
    guard let url = urlIn,
          fileExists(url:url) else {
      dbgPrintWithFunc(self, "File doesn't exist - \(String(describing: urlIn)).")
      return
    }
    
    do {
      try FileManager.default.removeItem(at: url)
    } catch let error as NSError {
      assertionFailure("Failed to remove file - \(url). Error - \(error.localizedDescription)")
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
   
   - Note: SHOULD use url.path instead of url.absoluteString if get local path from url.
   
   - Parameter createDirectoryAfterDeletion: Indicates whether to create the directory after the deletion.
   */
  public static func removeDirectory(path: String, createDirectoryAfterDeletion: Bool = false) {
    removeDirectory(url: URL(fileURLWithPath: path), createDirectoryAfterDeletion: createDirectoryAfterDeletion)
  }
  
  public static func removeDirectory(url: URL?, createDirectoryAfterDeletion: Bool = false) {
    removeFile(url)
    
    if createDirectoryAfterDeletion {
      createDirectoryIfNeeded(at: url)
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
  
  public static func createDirectoryIfNeeded(at url: URL?) {
    guard let url = url.assertIfNil else {
      return
    }
    createDirectoryIfNeeded(at: url.path)
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
