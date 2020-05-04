import Foundation

public class HashableHelper {  
  public static func isEqual(a: Any, b: Any) -> Bool {
    guard let a = a as? AnyHashable, let b = b as? AnyHashable else { return false }
    return a == b
  }
}
