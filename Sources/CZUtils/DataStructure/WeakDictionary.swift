import Foundation

/**
 Dictionary that  holds weak reference to the values.
 
 - Note: value with weak rerefence in`NSMapTable`  isn't released immediately after its scope.
 */
public class WeakDictionary<Key: Hashable, Value: AnyObject>: NSObject, ExpressibleByDictionaryLiteral {
  public typealias DictionaryType = Dictionary<Key, WeakWrapper<Value>>
  
  private var underlyingDictionary: DictionaryType
  
  public override init() {
    self.underlyingDictionary = DictionaryType()
    super.init()
  }
  
  public init(dictionary: DictionaryType) {
    underlyingDictionary = dictionary
    super.init()
  }
    
  public required init(dictionaryLiteral elements: (Key, Value)...) {
    underlyingDictionary = DictionaryType()
    for (key, value) in elements {
      underlyingDictionary[key] = WeakWrapper(value)
    }
    super.init()
  }
  
  public var isEmpty: Bool {
    return count == 0
  }
  
  public var count: Int {
    return values.count
  }
  
  public var keys: [Key] {
    return Array(underlyingDictionary.keys)
  }
  
  public var values: [Value] {
    return underlyingDictionary.values.compactMap { $0.element }
  }
  
  // MARK: - Public methods
  
  @discardableResult
  public func updateValue(_ value: Value, forKey key: Key) -> Value? {
    let valueWrapper = WeakWrapper(value)
    return underlyingDictionary.updateValue(valueWrapper, forKey: key)?.element
  }
  
  @discardableResult
  public func removeValue(forKey key: Key) -> Value? {
    underlyingDictionary.removeValue(forKey: key)?.element
  }
  
  // MARK: - Subscripts
  
  public subscript (key: Key) -> Value? {
    get {
      underlyingDictionary[key]?.element
    }
    set {
      if let newValue = newValue {
        updateValue(newValue, forKey: key)
      } else {
        removeValue(forKey: key)
      }
    }
  }
  
}

