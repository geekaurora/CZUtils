//
//  Error+.swift
//  CZUtils
//
//  Created by Cheng Zhang on 8/10/19.
//  Copyright © 2019 Cheng Zhang. All rights reserved.
//

import Foundation

// MARK: - Error

public extension Error {
  var retrievedCode: Int {
    return (self as NSError).code
  }

  /// Detailed description including the `userInfo` variable.
  var cz_description: String {
    (self as NSError).cz_description
  }
}

// MARK: - NSError

public extension NSError {
  /// Detailed description including the `userInfo` variable.
  var cz_description: String {
    var description = "\(self)"

    var userInfoDataString = ""
    if let userInfoData = userInfo["data"] as? Data {
      if let userInfoDataDict: [String: Any]? = CZHTTPJsonSerializer.deserializedObject(with: userInfoData) {
        userInfoDataString = userInfoDataDict?.description ?? ""
      } else {
        userInfoDataString = String(data: userInfoData, encoding: .utf8) ?? ""
      }
      description += "\n\n" + "userInfo['data'] = \n\(userInfoDataString))"
    }

    return description
  }
}
