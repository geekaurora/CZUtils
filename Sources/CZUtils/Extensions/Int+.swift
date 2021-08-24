import Foundation

public extension Int {
  /**
   Returns formatted size string. e.g. 12M, 25K, 122.
   */
  var sizeString: String {
    let gSize = self / (1024 * 1024 * 1024)
    if gSize > 0 {
      return "\(gSize) G"
    }
    
    let mSize = self / (1024 * 1024)
    if mSize > 0 {
      return "\(mSize) M"
    }
    
    let kSize = self / 1024
    if kSize > 0 {
      return "\(kSize) K"
    }
    
    return "\(self)"
  }
}

extension Array where Element: BinaryInteger {
  /// The average value of all the items in the array
  public var average: Double {
    if self.isEmpty {
      return 0.0
    } else {
      let sum = self.reduce(0, +)
      return Double(sum) / Double(self.count)
    }
  }
  
}

extension Array where Element: BinaryFloatingPoint {
  /// The average value of all the items in the array
  public var average: Double {
    if self.isEmpty {
      return 0.0
    } else {
      let sum = self.reduce(0, +)
      return Double(sum) / Double(self.count)
    }
  }
  
}
