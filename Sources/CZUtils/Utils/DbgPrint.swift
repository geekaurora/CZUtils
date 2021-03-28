import Foundation

public func dbgPrint(type: DbgPrintType = .`default`,
                     _ item: CustomStringConvertible) {
  let text = type.prefix + item.description
  #if DEBUG
  print(text)
  #endif
}

/**
 Automatically print the current object type and function name.
 Usage: `dbgPrintWithFunc(self, "someString")`
 */
public func dbgPrintWithFunc(_ object: Any,
                             function: String = #function,
                             _ item: CustomStringConvertible) {
  let objectAndFunction = "\(type(of: object)).\(function) - "
  let text = objectAndFunction + item.description
  #if DEBUG
  print(text)
  #endif
}

public enum DbgPrintType {
  case `default`
  case warning
  case error
  
  var prefix: String {
    switch self {
    case .`default`: return ""
    case .warning: return "[Warning] "
    case .error: return "[Error] "
    }
  }
}
