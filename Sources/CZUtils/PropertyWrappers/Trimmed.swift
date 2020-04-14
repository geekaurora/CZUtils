import Foundation

/**
 Trimmed string by trimming whitespaces and new lines.
 e.g.
 struct Post {
     @Trimmed var title: String
     @Trimmed var body: String
 }
 */
@propertyWrapper
struct Trimmed {
  private(set) var value: String = ""
  
  var wrappedValue: String {
    get { value }
    set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
  }
  
  init(wrappedValue initialValue: String) {
    self.wrappedValue = initialValue
  }
}
