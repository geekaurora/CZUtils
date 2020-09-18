//
//  CZHTTPJsonSerializer.swift
//  CZNetworking
//
//  Created by Cheng Zhang on 1/7/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation

/// Convenience class to accomplish JSON serializing/deserializing
open class CZHTTPJsonSerializer {
  public static func url(baseURL: URL, params: [AnyHashable: Any]?) -> URL {
    guard let paramsString = CZHTTPJsonSerializer.string(with: params),
      !paramsString.isEmpty else {
        return baseURL
    }
    let jointer = baseURL.absoluteString.contains("?") ? "&" : "?"
    let urlString = baseURL.absoluteString + jointer + paramsString
    return URL(string: urlString)!
  }
  
  /// Return serilized string from params
  public static func string(with params: [AnyHashable: Any]?) -> String? {
    guard let params = params as? [AnyHashable: CustomStringConvertible] else { return nil }
    let sortedKeys: [AnyHashable] = {
      if let keys = Array(params.keys) as? [String] {
        return keys.sorted()
      } else {
        return Array(params.keys)
      }
    }()
    let res = sortedKeys.map{ key in
      let value: String = {
        guard let value = params[key] else {
          return "unsupported"
        }
        return String(describing: value).urlEncoded
      }()
      return"\(key)=\(value)"
    }.joined(separator: "&")
    return res
  }
  
  /// Return JSONData with input Diciontary/Array
  public static func jsonData(with object: Any?) -> Data? {
    guard let object = object else { return nil }
    assert(JSONSerialization.isValidJSONObject(object), "Invalid JSON object.")
    do {
      let jsonData = try JSONSerialization.data(withJSONObject: object, options: [])
      return jsonData
    } catch let error {
      assertionFailure("Failed to serialize params to JSON. Error: \(error)")
      return nil
    }
  }
  
  /// Return nested deserialized object composed of various class types with input jsonData
  ///
  /// - Params:
  ///   - jsonData        : Input JSON data
  ///   - removeNull      : Remove any NSNull if exists
  /// - Returns           : Nested composition of NSDictionary, NSArray, NSSet, NSString, NSNumber
  public static func deserializedObject<T>(with jsonData: Data?, removeNull: Bool = true) -> T? {
    guard let jsonData = jsonData else { return nil }
    do {
      let deserializedData = try JSONSerialization.jsonObject(with: jsonData, options:[])
      return deserializedData as? T
    } catch let error as NSError {
      dbgPrint("Parsing error: \(error.localizedDescription)")
    }
    return nil
  }
  
  /// Return string value with input Diciontary/Array.
  public static func stringify(_ object: Any?, encoding: String.Encoding = .utf8) -> String? {
    guard let data = jsonData(with: object).assertIfNil else { return nil }
    return String(data: data, encoding: encoding)
  }
}





