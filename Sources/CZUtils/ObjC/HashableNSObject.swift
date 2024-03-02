import Foundation

/// ObjC bridging class to bridge NSObjectProtocol to Swift Hashable.
public struct HashableNSObject<T: NSObjectProtocol>: Hashable {
  private let value: T

  init(_ value: T) {
    self.value = value
  }

  public static func == (lhs: HashableNSObject<T>, rhs: HashableNSObject<T>) -> Bool {
    return lhs.value.isEqual(rhs.value)
  }

  public func hash(into hasher: inout Hasher) {
    hasher.combine(value.hash)
  }
}
