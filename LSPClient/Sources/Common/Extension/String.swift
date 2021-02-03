//
//  String.swift
//  LSPClient
//
//  Created by Shion on 2020/09/16.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

extension String {

    static let tab = "\u{0009}"
    static let lineFeed = "\u{000A}"

    @inlinable var range: NSRange {
        NSMakeRange(0, length)
    }

    @inlinable var length: Int {
        (self as NSString).length
    }

    @inlinable var monospaceCount: Int {
        let double = (utf8.count - utf16.count) / 2
        let single = count - double
        return single + double * 2
    }

    @inlinable func enumerateLines(regex: NSRegularExpression, invoking body: (String) -> Void) {
        var matches = regex.matches(in: self, options: [], range: range).compactMap({ $0.range })
        if matches.isEmpty {
            body(self)

        } else {
            let nsString = self as NSString
            if let lastMatche = matches.last, lastMatche.upperBound < nsString.length - 1 {
                matches.append(NSMakeRange(nsString.length - 1, lastMatche.length))
            }
            var location = 0
            for range in matches {
                let range = NSMakeRange(location, range.upperBound - location)
                body(nsString.substring(with: range))
                location = range.upperBound
            }
        }
    }

    @inlinable func removeIndent(with str: String) -> Substring? {
        if self.hasPrefix(str) {
            return self.dropFirst(str.count)
        }

        let indent = str.prefix(1)
        if self.hasPrefix(indent) {
            var result = self.dropFirst(1)
            for _ in 1 ..< str.count {
                if !result.hasPrefix(indent) {
                    return result
                }
                result = result.dropFirst(1)
            }
            return result
        }

        return nil
    }

}

