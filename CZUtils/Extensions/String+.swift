//
//  NSString+Additions
//
//  Created by Cheng Zhang on 1/5/16.
//  Copyright © 2016 Cheng Zhang. All rights reserved.
//

import Foundation

public extension String {
    /**
     http://stackoverflow.com/questions/24551816/swift-encode-url
     http://stackoverflow.com/questions/37376196/encode-url-with-http

     URLHostAllowedCharacterSet      "#%/<>?@\^`{|}
     URLQueryAllowedCharacterSet     "#%<>[\]^`{|}
     URLFragmentAllowedCharacterSet  "#%<>[\]^`{|}
     URLPasswordAllowedCharacterSet  "#%/:<>?@[\]^`{|}
     URLPathAllowedCharacterSet      "#%;<>?[\]^`{|}
     URLUserAllowedCharacterSet      "#%/:<>?@[\]^`
     */
    public func urlEncoded()-> String {
        guard index(of: "%") == nil else { return self }
        let mutableString = NSMutableString(string: self)
        let urlEncoded = mutableString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed)
        return urlEncoded ?? ""
    }

    /**
     Search substrings that matches regex pattern

     - parameter regex: the regex pattern
     - parameter excludeRegEx: indicates whether returned substrings exclude regex pattern iteself

     - returns: all matched substrings
     */
    public func search(regex: String, excludeRegEx: Bool = true) -> [String] {
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
}
