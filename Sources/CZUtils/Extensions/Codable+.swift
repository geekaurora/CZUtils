//
//  Codable+.swift
//  CZUtils
//
//  Created by Cheng Zhang on 12/31/18.
//  Copyright © 2018 Cheng Zhang. All rights reserved.
//

import Foundation

public class CodableHelper {
  
  // MARK: File - Read
  
  /// Decode model from specified file with `pathUrl`.
  ///
  /// - Parameter pathUrl: pathUrl of file. NOTE: `pathUrl` should be initialized with `URL(fileURLWithPath:)`.
  /// - Returns: the decoded model
  public static func decode<T: Decodable>(_ pathUrl: URL, ignoreAssertion: Bool = false) -> T? {
    do {
      let jsonData = try Data(contentsOf: pathUrl)
      let model = try JSONDecoder().decode(T.self, from: jsonData)
      return model
    } catch {
      if !ignoreAssertion {
        assertionFailure("Failed to decode JSON file \(pathUrl) of \(T.self). Error - \(error.localizedDescription)")
      }
      return nil
    }
  }
  
  /// Decode model from specified file with `pathString`.
  ///
  /// - Parameter pathString: pathString of file.
  /// - Returns: the decoded model
  public static func decode<T: Decodable>(_ pathString: String, ignoreAssertion: Bool = false) -> T? {
    let pathUrl = URL(fileURLWithPath: pathString)
    return decode(pathUrl, ignoreAssertion: ignoreAssertion)
  }
  
  /// Decode model from input Data.
  ///
  /// - Parameter data: serialized data
  /// - Returns: the decoded model
  public static func decode<T: Decodable>(_ data: Data?) -> T? {
    guard let data = data else { return nil }
    do {
      let model = try JSONDecoder().decode(T.self, from: data)
      return model
    } catch {
      let dataDescription = CZHTTPJsonSerializer.describing(data: data)
      assertionFailure("Failed to decode data of `\(T.self)`. Error - \(error.localizedDescription). \njsonData = \(dataDescription)")
      return nil
    }
  }
  
  /// Decode model array from input data or JsonObject.
  ///
  /// - Note: `decodeArray` manually decodes data to Codable models for the ease of debugging.
  ///
  /// - Parameter data: serialized data
  /// - Returns: the decoded model array
  public static func decodeArray<T: Decodable>(_ input: Any?) -> [T]? {
    var parsedDicts: [CZDictionary]?
    if let data = input as? Data {
      // Parse Data.
      parsedDicts = CZHTTPJsonSerializer.deserializedObject(with: data).assertIfNil
    } else {
      // Parse JsonObject.
      parsedDicts = (input as? [CZDictionary]).assertIfNil
    }
    
    guard let dicts = parsedDicts.assertIfNil else { return nil }
    // Decode each individual model with its corresponding data.
    let result: [T] = dicts.compactMap { dict in
      guard let modelData = CZHTTPJsonSerializer.jsonData(with: dict).assertIfNil,
            let model: T = Self.decode(modelData) else {
        return nil
      }
      return model
    }
    return result
  }
  
  /// Decode model from input JsonObject.
  ///
  /// - Parameter data: serialized data
  /// - Returns: the decoded model
  public static func decodeObject<T: Decodable>(_ jsonObject: Any?) -> T? {
    guard let data = CZHTTPJsonSerializer.jsonData(with: jsonObject) else {
      return nil      
    }
    do {
      let model = try JSONDecoder().decode(T.self, from: data)
      return model
    } catch {
      assertionFailure("Failed to decode data of `\(T.self)`. Error - \(error.localizedDescription)")
      return nil
    }
  }
  
  /// Encode input model into Data.
  ///
  /// - Parameter model: model to be encoded
  /// - Returns: encoded data
  public static func encode<T: Encodable>(_ model: T?) -> Data? {
    guard let model = model else { return nil }
    do {
      let data = try JSONEncoder().encode(model)
      return data
    } catch {
      assertionFailure("Failed to encode model. Error - \(error.localizedDescription)")
      return nil
    }
  }
}

// MARK: - Encodable

public extension Encodable {
  /// Encodes an encodable object as a JSON object.
  var asObject: Any? {
    do {
      let data = try JSONEncoder().encode(self)
      let result = try JSONSerialization.jsonObject(with: data)
      return result
    } catch {
      assertionFailure("Failed to decode the model. Error - \(error.localizedDescription)")
      return nil
    }
  }
  
  /// Encodes an encodable object as a JSON object array.
  var asArray: [Any]? {
    return self.asObject as? [Any]
  }
  
  /// Transform the current object to a dictionary.
  var dictionaryVersion: [AnyHashable : Any] {
    return (self.asObject as? [AnyHashable: Any]).assertIfNil ?? [:]
  }
  
  /// Verify whether current obj equals to other obj.
  ///
  /// - Parameter other: the other obj to compare
  /// - Returns: true if equals, false otherwise
  func isEqual(toCodable other: Any) -> Bool {
    guard let other = other as? Encodable else {
      // let selfClass = type(of: self) as? AnyClass,
      // let otherClass = type(of: other) as? AnyClass,
      // NSStringFromClass(selfClass) == NSStringFromClass(otherClass)
      return false
    }
    return (dictionaryVersion as NSDictionary).isEqual(to: other.dictionaryVersion)
  }
  
  /// Description of model, needs to mark `CustomStringConvertible` conformance explicitly.
  var description: String {
    return prettyDescription
  }
  
  var prettyDescription: String {
    return dictionaryVersion.prettyDescription
  }
  
  var descriptionSortedByKey: String {
    return dictionaryVersion.descriptionSortedByKey
  }
  
  /// Retrieve value from `dotedKey`, compatible with multi-dot in keyPath. e.g. "user.profile.fullName"
  func value<T>(forDotedKey dotedKey: String) -> T? {
    return dictionaryVersion.value(forDotedKey: dotedKey) as? T
  }
  
  // MARK: File - Write
  
  /// Saves the object to `filePath`.
  ///
  /// - Params:
  ///   - object                :   The JSON object. e.g. Dictionary, Array etc.
  ///   - FilePath            :   The file path to be saved to.
  /// - Returns              : True if succeed, false otherwise.
  @discardableResult
  func saveToFilePath(_ filePath: String, atomically: Bool = true)-> Bool {
    guard let data = CodableHelper.encode(self).assertIfNil else {
      return false
    }
    (data as NSData).write(toFile: filePath, atomically: atomically)
    return true
  }
}

// MARK: - Decodable

public extension Decodable {
  // MARK: JSON

  static func decode(fromJSONObject jsonObject: Any) -> Self? {
    guard let data = try? JSONSerialization.data(withJSONObject: jsonObject),
          let result = try? JSONDecoder().decode(Self.self, from: data) else {
      return nil
    }
    return result
  }
}

// MARK: - Codable

public extension Encodable where Self: Decodable {
  
  // MARK: NSCopying
  
  func copy(with zone: NSZone?) -> Any  {
    return codableCopy(with: zone)
  }
  
  func codableCopy(with zone: NSZone? = nil) -> Self {
    do {
      let encodedData = try JSONEncoder().encode(self)
      let copy = try JSONDecoder().decode(type(of: self), from: encodedData)
      return copy
    } catch {
      assertionFailure("Failed to copy the object. Error - \(error.localizedDescription)")
      return self
    }
  }
}

// MARK: - KeyedDecodingContainer

public extension KeyedDecodingContainer {
  /// Decodes a value of the given type for the given `key`.
  /// e.g. `name = try values.cz_decode(key: .name)`
  func cz_decode<T>(key: K) throws -> T where T : Decodable {
    return try decode(T.self, forKey: key)
  }
  
  /// Decodes a value of the given type for the given `key`, if present. Otherwise, return `defaultValue`.
  /// e.g. `diffId = try values.cz_decodeIfPresent(key: .diffId, defaultValue: UUID())`
  func cz_decodeIfPresent<T>(key: K, defaultValue: T) throws -> T where T : Decodable {
    return try decodeIfPresent(T.self, forKey: key) ?? defaultValue
  }
}
