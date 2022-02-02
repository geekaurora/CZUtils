import Foundation

public func dbgPrint(type: DbgPrintType = .`default`,
                     _ item: CustomStringConvertible) {
  _dbgPrint(type: type, item)
}

public func _dbgPrint(type: DbgPrintType = .`default`,
                     _ item: CustomStringConvertible) {
  let text = type.prefix + item.description
  #if DEBUG
  print(text)
  #endif
}

/**
 Automatically print the current object type and function name.
 Usage: `dbgPrintWithFunc(self, "someString")`
 
 - Parameters:
    - withDividers: Indicates whether to show dividers above and below the text.
 */
public func dbgPrintWithFunc(_ object: Any,
                             type: DbgPrintType = .`default`,
                             function: String = #function,
                             withDividers: Bool = false,
                             _ item: CustomStringConvertible) {
  let objectAndFunction = "\(Swift.type(of: object)).\(function)) - "
  let text = objectAndFunction + item.description
  if withDividers {
    dbgPrintWithDividers(type: type, text)
  } else {
    dbgPrint(type: type, text)
  }
}

/**
 Print the `text` with  dividers above and beneath it.
 */
public func dbgPrintWithDividers(type: DbgPrintType = .default,
                                 _ text: String,
                                 dividerChar: String = "=",
                                 dividerLength: Int = 72,
                                 prefix: String = "\n",
                                 surfix: String? = "\n") {
  // Print the prefix.
  dbgPrint(prefix)
  
  // Print the text with dividers.
  let divider = (0..<dividerLength).reduce("") { (res, _) in res + dividerChar }
  dbgPrint(divider)
  dbgPrint(type: type, text)
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
