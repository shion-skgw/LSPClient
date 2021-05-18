//
//  String.swift
//  LSPClient
//
//  Created by Shion on 2020/09/16.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

extension String {

    @usableFromInline static let endOfLineRegex = try! NSRegularExpression(pattern: "^.*(\n|$)", options: .anchorsMatchLines)

//    @inlinable var monospaceCount: Int {
//        let double = (utf8.count - utf16.count) / 2
//        let single = count - double
//        return single + double * 2
//    }

    @inlinable var range: NSRange {
        NSMakeRange(.zero, self.utf16.count)
    }

    @inlinable var length: Int {
        self.utf16.count
    }

    @inlinable func replacing(of target: String, with replacement: String) -> String {
        return self.replacingOccurrences(of: target, with: replacement, options: .regularExpression)
    }

    @inlinable func lines(range: NSRange) -> [String] {
        let string = self as NSString
        return String.endOfLineRegex.matches(in: self, range: range).map({ string.substring(with: $0.range) })
    }

    @inlinable func lineRanges(range: NSRange) -> [(number: Int, range: NSRange)] {
        let upperBound = range.length != .zero ? range.upperBound : min(range.upperBound + 1, self.length)
        return String.endOfLineRegex.matches(in: self, range: NSMakeRange(.zero, upperBound))
            .enumerated()
            .filter({ range.lowerBound <= $0.element.range.upperBound })
            .map({ ($0.offset, $0.element.range) })
    }

    @inlinable func index(offsetBy: Int) -> Index {
        return index(startIndex, offsetBy: offsetBy)
    }

    @inlinable func changes(from: String) -> (range: NSRange, text: String) {
        let difference = self.difference(from: from)

        guard !difference.isEmpty, difference.isSequential else {
            return (from.range, self)
        }

        let remove = difference.removals
        let insert = difference.insertions

        switch (remove.first?.offset, remove.last?.offset, insert.first?.offset, insert.last?.offset) {
        case (nil, nil, let insertMin?, let insertMax?):
            let editRange = from.index(offsetBy: insertMin)..<from.index(offsetBy: insertMin)
            let textRange = self.index(offsetBy: insertMin)..<self.index(offsetBy: insertMax + 1)
            return (NSRange(editRange, in: from), String(self[textRange]))

        case (let removeMin?, let removeMax?, nil, nil):
            let editRange = from.index(offsetBy: removeMin)..<from.index(offsetBy: removeMax + 1)
            return (NSRange(editRange, in: from), "")

        case (let removeMin?, let removeMax?, let insertMin?, let insertMax?):
            let editRange = from.index(offsetBy: removeMin)..<from.index(offsetBy: removeMax + 1)
            let textRange = self.index(offsetBy: insertMin)..<self.index(offsetBy: insertMax + 1)
            return (NSRange(editRange, in: from), String(self[textRange]))

        default:
            fatalError()
        }
    }

}
