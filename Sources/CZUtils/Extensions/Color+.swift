import UIKit

public extension UIColor {
  /// Returns the RGB, alpha values.
  var rgba: ColorRGBA {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0
    
    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return ColorRGBA(red: red, green: green, blue: blue, alpha: alpha)
  }
}

/// The RGB, alpha values.
public struct ColorRGBA {
  let red: CGFloat
  let green: CGFloat
  let blue: CGFloat
  let alpha: CGFloat
}
