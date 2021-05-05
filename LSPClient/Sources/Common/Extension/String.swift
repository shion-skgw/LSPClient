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
        NSMakeRange(0, length)
    }

    @inlinable var length: Int {
        (self as NSString).length
    }

    @inlinable func lines(range: NSRange) -> [Substring] {
        return String.endOfLineRegex.matches(in: self, range: range).map() {
            self[Range($0.range, in: self)!]
        }
    }

    @inlinable func lineRanges(range: NSRange) -> [(line: Int, range: Range<Index>)] {
        var lineNumber = 0
        return String.endOfLineRegex.matches(in: self, range: NSMakeRange(.zero, range.upperBound)).compactMap() {
            let result = range.lowerBound <= $0.range.upperBound ? (lineNumber, Range($0.range, in: self)!) : nil
            lineNumber += 1
            return result
        }
    }

    @inlinable func index(offsetBy: Int) -> Index {
        return index(startIndex, offsetBy: offsetBy)
    }

    @inlinable func changes(from: String) -> (range: Range<Index>, text: String) {
        let difference = self.difference(from: from)

        guard !difference.isEmpty, difference.isSequential else {
            return (from.startIndex..<from.endIndex, self)
        }

        let removeMin = difference.removals.first?.offset
        let removeMax = difference.removals.last?.offset
        let insertMin = difference.insertions.first?.offset
        let insertMax = difference.insertions.last?.offset

        switch (removeMin, removeMax, insertMin, insertMax) {
        case (nil, nil, let insertMin?, let insertMax?):
            let editRange = from.index(offsetBy: insertMin)..<from.index(offsetBy: insertMin)
            let textRange = self.index(offsetBy: insertMin)..<self.index(offsetBy: insertMax + 1)
            return (editRange, String(self[textRange]))

        case (let removeMin?, let removeMax?, nil, nil):
            let editRange = from.index(offsetBy: removeMin)..<from.index(offsetBy: removeMax + 1)
            return (editRange, "")

        case (let removeMin?, let removeMax?, let insertMin?, let insertMax?):
            let editRange = from.index(offsetBy: removeMin)..<from.index(offsetBy: removeMax + 1)
            let textRange = self.index(offsetBy: insertMin)..<self.index(offsetBy: insertMax + 1)
            return (editRange, String(self[textRange]))

        default:
            fatalError()
        }
    }

}
