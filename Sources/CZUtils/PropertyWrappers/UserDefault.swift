import Foundation

/**
 Porperty wrapper that  sets `value` for `key` to UserDefaults.
 
 ### Usage
 ```
 struct UserDefaultsConfig {
   @UserDefault("has_seen_app_introduction", defaultValue: false)
   static var hasSeenAppIntroduction: Bool
 }
 ```
 */
@propertyWrapper
public struct UserDefault<T> {
  let key: String
  let defaultValue: T
  
  init(_ key: String, defaultValue: T) {
    self.key = key
    self.defaultValue = defaultValue
  }
  
  /// `wrappedValue`: custom get/set realValue of perperty.
  public var wrappedValue: T {
    get {
      return UserDefaults.standard.object(forKey: key) as? T ?? defaultValue
    }
    set {
      UserDefaults.standard.set(newValue, forKey: key)
    }
  }
}

