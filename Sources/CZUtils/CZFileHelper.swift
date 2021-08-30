import Foundation

/// Helper class for file related methods 
@objc open class CZFileHelper: NSObject {
  @objc public static var documentDirectory: String {
    return NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] + "/"
  }
  
  /**
   Returns the shared writable folder URL of the simulator. It can be used for sharing data between app and UITest.
  
   - Note: It only works for Simulator.
   
   ### Sample
    /Users/<userName>/Library/Developer/CoreSimulator/Devices/<GroupId>/data/Library/Shared
   */
  public static func sharedGroupFolderURL() -> URL? {
    guard let simulatorSharedDir = ProcessInfo().environment["SIMULATOR_SHARED_RESOURCES_DIRECTORY"] else {
      assertionFailure("Failed to get SIMULATOR_SHARED_RESOURCES_DIRECTORY from ProcessInfo.")
      return nil
    }
    let simulatorHomeDirURL = URL(fileURLWithPath: simulatorSharedDir)
    let cachesDirURL = simulatorHomeDirURL.appendingPathComponent("Library/Caches")
    assert(FileManager.default.isWritableFile(atPath: cachesDirURL.path), "Cannot write to simulator Caches directory - \(cachesDirURL)")
    
    let sharedFolderURL = cachesDirURL.appendingPathComponent("Shared")
    createDirectoryIfNeeded(at: sharedFolderURL)
//    do {
//      try FileManager.default.createDirectory(at: sharedFolderURL, withIntermediateDirectories: true, attributes: nil)
//    } catch {
//      assertionFailure("Failed to create shared folder \(sharedFolderURL). error - \(error)")
//    }
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
  
  public static func createDirectoryIfNeeded(at url: URL?) {
    guard let url = url else {
      return
    }
    if !FileManager.default.fileExists(atPath: url.absoluteString) {
      do {
        try FileManager.default.createDirectory(at: url, withIntermediateDirectories: true, attributes: nil)
      } catch {
        assertionFailure("Failed to create the directory! Error - \(error.localizedDescription); url - \(url)")
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
