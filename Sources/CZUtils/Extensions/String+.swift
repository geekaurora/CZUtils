//
//  String+
//
//  Created by Cheng Zhang on 1/5/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation
import CommonCrypto

public extension String {
  /**
   Encodes String for URL by converting illegal characters.

   URLHostAllowedCharacterSet      "#%/<>?@\^`{|}
   URLQueryAllowedCharacterSet     "#%<>[\]^`{|}
   URLFragmentAllowedCharacterSet  "#%<>[\]^`{|}
   URLPasswordAllowedCharacterSet  "#%/:<>?@[\]^`{|}
   URLPathAllowedCharacterSet      "#%;<>?[\]^`{|}
   URLUserAllowedCharacterSet      "#%/:<>?@[\]^`

   http://stackoverflow.com/questions/24551816/swift-encode-url
   */
  var urlEncoded: String {
    guard firstIndex(of: "%") == nil else { return self }
    let mutableString = NSMutableString(string: self)
    let urlEncoded = mutableString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
    return urlEncoded ?? ""
  }

  /// Returns alphanumeric string.
  var alphanumeric: String {
    let pattern = "[^A-Za-z0-9]+"
    let res = replacingOccurrences(
      of: pattern,
      with: "",
      options: [.regularExpression])
    return res
  }

  /// Returns Int value.
  var intValue: Int? {
    return Int(self)
  }

  /// MD5 HashValue: Should #import <CommonCrypto/CommonCrypto.h> in your Bridging-Header file
  var MD5: String {
    let length = Int(CC_MD5_DIGEST_LENGTH)
    var digest = [UInt8](repeating: 0, count: length)

    if let d = self.data(using: String.Encoding.utf8) {
      _ = d.withUnsafeBytes { (body: UnsafePointer<UInt8>) in
        CC_MD5(body, CC_LONG(d.count), &digest)
      }
    }

    return (0..<length).reduce("") {
      $0 + String(format: "%02x", digest[$1])
    }
  }

  /**
   Search substrings that matches regex pattern

   - parameter regex: the regex pattern
   - parameter excludeRegEx: indicates whether returned substrings exclude regex pattern iteself

   - returns: all matched substrings
   */
  func search(regex: String, excludeRegEx: Bool = true) -> [String] {
    guard let regex = try? NSRegularExpression(pattern: regex, options: []) else {
      return []
    }
    let string = self as NSString
    let results  = regex.matches(in: self, options: [], range: NSMakeRange(0, string.length))
    return results.compactMap { result in
      guard result.numberOfRanges > 0 else {
        return nil
      }
      let i = excludeRegEx ? (result.numberOfRanges - 1) : 0
      return result.range(at: i).location != NSNotFound ? string.substring(with: result.range(at: i)) : nil
    }
  }

  func isEqualCaseInsensitively(to string: String) -> Bool {
    return self.lowercased() == string.lowercased()
  }

  /// Removes the `prefix` from the string.
  func removePrefix(_ prefix: String) -> String {
    guard hasPrefix(prefix) else { return self }
    return String(dropFirst(prefix.count))
  }

  /// Removes the `suffix` from the string.
  func removeSuffix(_ suffix: String) -> String {
    guard hasSuffix(suffix) else { return self }
    return String(dropLast(suffix.count))
  }

  /// Extracts the enclosed string between `startChar` and `endChar`.
  func cz_extractEnclosedString(startChar: Character,
                             endChar: Character,
                             shouldIncludeBoundaries: Bool = true) -> String {
    guard var startIndex = firstIndex(of: startChar),
          var endIndex = lastIndex(of: endChar),
          startIndex < endIndex
    else {
      return self
    }
    if !shouldIncludeBoundaries {
      startIndex = self.index(after: startIndex)
      endIndex = self.index(before: endIndex)
    }
    return String(self[startIndex..<self.index(after: endIndex)])
  }
  
  /**
   Returns splitted Strings with input `separator`, `maxSplits`, `omittingEmptySubsequences`.
   */
  func splitToStrings(separator: Character,
                      maxSplits: Int = Int.max,
                      omittingEmptySubsequences: Bool = true) -> [String] {
    return split(
      separator: separator,
      maxSplits: maxSplits,
      omittingEmptySubsequences: omittingEmptySubsequences)
    .map { String($0) }
  }

  /**
   Returns file type of the current string if applicable.

   e.g. return "mp3" for "file:///user/some/path/file.mp3"
   */
  func fileType(includingDot: Bool = false) -> String {
    guard let res = split(separator: ".").last,
          res.firstIndex(of: "/") == nil,
          res.firstIndex(of: "\\") == nil else {
      return ""
    }
    let dotString = includingDot ? "." : ""
    return String(dotString + res)
  }
}

public extension NSAttributedString {
  static func string(withHtml html: String) -> NSAttributedString? {
    let attributedString = try? NSAttributedString(
      data: html.data(using: .utf8)!,
      options: [.documentType: NSAttributedString.DocumentType.html, .characterEncoding: String.Encoding.utf8.rawValue],
      documentAttributes: nil)
    return attributedString
  }
}
