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

}

// MARK: - EditorViewController

extension String {

    @inlinable var monospaceCount: Int {
        let double = (utf8.count - utf16.count) / 2
        let single = count - double
        return single + double * 2
    }

    @usableFromInline static let endOfLineRegex = try! NSRegularExpression(pattern: "(.*\n|[^\n]+$)")

    @inlinable func enumerateLines(range: NSRange, invoking body: (Substring) -> Void) {
        String.endOfLineRegex.enumerateMatches(in: self, range: range) {
            result, _, _ in
            guard let nsRange = result?.range, let range = Range(nsRange, in: self) else {
                return
            }
            body(self[range])
        }
    }


    @inlinable func changes(from: String) -> (range: NSRange, text: String) {
        var (removeMin, removeMax, insertMin, insertMax) = (-1, -1, -1, -1)
        for diff in self.utf16.difference(from: from.utf16) {
            switch diff {
            case .remove(let offset, _, _):
                if removeMax == -1 {
                    (removeMax, removeMin) = (offset, offset)
                } else if removeMin - 1 == offset {
                    removeMin = offset
                } else {
                    return (from.range, self)
                }
            case .insert(let offset, _, _):
                if insertMin == -1 {
                    (insertMin, insertMax) = (offset, offset)
                } else if insertMax + 1 == offset {
                    insertMax = offset
                } else {
                    return (from.range, self)
                }
            }
        }

        switch (removeMin != -1, insertMin != -1) {
        case (true, true):
            let beforeRange = NSMakeRange(removeMin, removeMax - removeMin + 1)
            let textRange = NSMakeRange(insertMin, insertMax - insertMin + 1)
            let text = (self as NSString).substring(with: textRange)
            return (beforeRange, text)

        case (true, false):
            let beforeRange = NSMakeRange(removeMin, removeMax - removeMin + 1)
            return (beforeRange, "")

        case (false, true):
            let beforeRange = NSMakeRange(insertMin, 0)
            let textRange = NSMakeRange(insertMin, insertMax - insertMin + 1)
            let text = (self as NSString).substring(with: textRange)
            return (beforeRange, text)

        case (false, false):
            return (from.range, self)
        }
    }

}
