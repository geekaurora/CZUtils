import Foundation

/**
 Trimmed string by trimming whitespaces and new lines.
 e.g.
 struct Post {
     @String.Trimmed var title: String
     @String.Trimmed var body: String
 }
 */
public extension String {

  @propertyWrapper
  struct Trimmed {
    private(set) var value: String = ""

    public init(wrappedValue initialValue: String) {
      self.wrappedValue = initialValue
    }

    public var wrappedValue: String {
      get { value }
      set { value = newValue.trimmingCharacters(in: .whitespacesAndNewlines) }
    }
  }
}
