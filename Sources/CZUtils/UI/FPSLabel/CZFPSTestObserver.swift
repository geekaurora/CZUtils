import Foundation

/**
 The result of CZFPSTestObserver.
 */
public class CZFPSTestObserverResult: Codable, CustomStringConvertible {
  public let fpsValues: [Double]
  public let badFPSs: [Double]
  public let averageFPS: Double
  
  public let date: Date
  public let deviceType: String
  
  private var filePath: String {
    let dateString = Date().simpleFileString
    return CZFileHelper.documentDirectory + dateString + ".txt"
  }
  
  public init(fpsValues: [Double], badFPSs: [Double]) {
    self.fpsValues = fpsValues
    self.badFPSs = badFPSs
    self.averageFPS = fpsValues.average.rounded()
    
    self.date = Date()
    self.deviceType = CZSystemInfo.getDeviceType()
  }
  
  public func hasBadFPS() -> Bool {
    return badFPSs.count > 0
  }
  
  public func saveToFile() {
    let saveFileResult = self.saveToFilePath(filePath)
    dbgPrintWithFunc(self, "\nResult = \(saveFileResult). Write the file - \(filePath)\n")
  }
}

/**
 CADisplayLink observer that observes FPS for FPS tests.
 */
public class CZFPSTestObserver {
  public static let shared = CZFPSTestObserver()
  
  public enum Constant {
    /// Threshold that determines whether the FPS value isn't performance.
    public static var fpsThreshold: Double = 50
    /// Threshold that determines whether to filter out the FPS value during the initialization.
    public static var initFPSThreshold: Double = 50
  }
  public private(set) var fpsValues = [Double]()
  
  public init() {}
  
  // MARK: - Start / Stop
  
  public func start() {
    CADisplayLinkMonitor.shared.addListener(self)
  }
  
  public func stop() {
    CADisplayLinkMonitor.shared.removeListener(self)
  }
  
  // MARK: - Results
  
  public func outputResults() -> CZFPSTestObserverResult {
    preprocessFPSValues()
    
    let badFPSs = self.badFPSs()
    let result = CZFPSTestObserverResult(fpsValues: fpsValues, badFPSs: badFPSs)
    result.saveToFile()
    return result
  }
  
  public func badFPSs() -> [Double] {
    return fpsValues.filter { $0 < Self.Constant.fpsThreshold }
  }
}

// MARK: - Private methods

private extension CZFPSTestObserver {
  
  /// Remove the slow FPS values during the initialization.
  func preprocessFPSValues() {
    defer {
      fpsValues = fpsValues.map { $0.rounded() }
    }
    
    guard fpsValues.count > 0,
          let index = fpsValues.firstIndex(where: { $0 >= Self.Constant.initFPSThreshold }) else {
      return
    }
    fpsValues = Array(fpsValues[index...])
  }
}

// MARK: - CADisplayLinkObserverProtocol

extension CZFPSTestObserver: CADisplayLinkObserverProtocol {
  public func handleUpdatedData(_ data: CZEventData?) {
    guard let displayLinkEventData = (data as? DisplayLinkEventData).assertIfNil,
          let fps = displayLinkEventData.fps.assertIfNil else {
      return
    }
    fpsValues.append(fps)
  }
}
