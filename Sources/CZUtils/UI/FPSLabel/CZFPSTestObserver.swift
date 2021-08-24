import Foundation

/**
 The result of CZFPSTestObserver.
 */
public class CZFPSTestObserverResult: Codable {
  public let fpsValues: [Double]
  public let badFPSs: [Double]
  
  private var filePath: String {
    return CZFileHelper.documentDirectory + "date" + ".txt"
  }
  
  public init(fpsValues: [Double], badFPSs: [Double]) {
    self.fpsValues = fpsValues
    self.badFPSs = badFPSs
  }
  
  public func hasBadFPS() -> Bool {
    return badFPSs.count > 0
  }
  
  public func saveToFile() {
    guard let data = CZHTTPJsonSerializer.jsonData(with: dictionaryVersion).assertIfNil else {
      return
    }
    (data as NSData).write(toFile: filePath, atomically: true)
    dbgPrintWithFunc(self, "Successfully write the file - \(filePath).")
    
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
    /// Threshold that determines to filter out the FPS value during the initialization.
    public static var initFPSThreshold: Double = 59
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
    
    let result = CZFPSTestObserverResult(fpsValues: fpsValues, badFPSs: badFPSs())
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
    guard fpsValues.count > 0,
          let index = fpsValues.firstIndex(where: { $0 >= Self.Constant.initFPSThreshold }).assertIfNil else {
      return
    }
    assert(index == 0, "The first FPS should be greater than `Constant.initFPSThreshold`.")
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
