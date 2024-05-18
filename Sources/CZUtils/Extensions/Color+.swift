import UIKit

public extension UIColor {
  /// Returns the RGB, alpha values.
  var rgba: (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat) {
    var red: CGFloat = 0
    var green: CGFloat = 0
    var blue: CGFloat = 0
    var alpha: CGFloat = 0

    getRed(&red, green: &green, blue: &blue, alpha: &alpha)
    return (red: red, green: green, blue: blue, alpha: alpha)
  }
}
