import Foundation

public func dbgPrint(type: DbgPrintType = .`default`,
                     withDividers: Bool = false,
                     _ item: CustomStringConvertible) {
  if withDividers {
    _dbgPrintWithDividers(type: type, item)
  } else {
    _dbgPrint(type: type, item)
  }
}

/**
 Automatically print the current object type and function name.
 Usage: `dbgPrintWithFunc(self, "someString")`
 
 - Parameters:
    - withDividers: Indicates whether to show dividers above and below the text.
 */
public func dbgPrintWithFunc(_ object: Any,
                             type: DbgPrintType = .`default`,
                             withDividers: Bool = false,
                             function: String = #function,
                             _ item: CustomStringConvertible) {
  let objectAndFunction = "\(Swift.type(of: object)).\(function)) - "
  let text = objectAndFunction + item.description
  dbgPrint(type: type, withDividers: withDividers, text)
}

public func _dbgPrint(type: DbgPrintType = .`default`,
                     _ item: CustomStringConvertible) {
  let text = type.prefix + item.description
  #if DEBUG
  print(text)
  #endif
}

/**
 Print the `text` with  dividers above and beneath it.
 */
public func _dbgPrintWithDividers(type: DbgPrintType = .default,
                           _ text: CustomStringConvertible,
                           dividerChar: String = "=",
                           dividerLength: Int = 72,
                           prefix: String = "\n",
                           surfix: String? = "\n") {
  // Print the prefix.
  _dbgPrint(prefix)
  
  // Print the text with dividers.
  let divider = (0..<dividerLength).reduce("") { (res, _) in res + dividerChar }
  _dbgPrint(divider)
  _dbgPrint(type: type, text)
  _dbgPrint(divider)
  
  // Print the surfix if presents.
  if let surfix = surfix {
    _dbgPrint(surfix)
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
