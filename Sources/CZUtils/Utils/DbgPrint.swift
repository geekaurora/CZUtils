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

/**
 Print the `text` with  dividers above and beneath it.
 */
public func dbgPrintWithDividers(_ text: String,
                                 dividerChar: String = "=",
                                 dividerLength: Int = 72,
                                 prefix: String = "\n",
                                 surfix: String? = "\n") {
  // Print the prefix.
  dbgPrint(prefix)
  
  // Print the text with dividers.
  let divider = (0..<dividerLength).reduce("") { (res, _) in res + dividerChar }
  dbgPrint(divider)
  dbgPrint(text)
  dbgPrint(divider)
  
  // Print the surfix if presents.
  if let surfix = surfix {
    dbgPrint(surfix)
  }
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
