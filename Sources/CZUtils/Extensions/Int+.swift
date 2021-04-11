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
