//
//  String.swift
//  LSPClient
//
//  Created by Shion on 2020/09/16.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

extension String {

    static let blank    = ""
    static let space    = " "
    static let lineFeed = "\n"
    static let tab      = "\t"


    // MARK: - Support for NSString

    @inlinable var range: NSRange {
        NSMakeRange(.zero, self.length)
    }

    @inlinable var length: Int {
        self.utf16.count
    }

    @inlinable subscript(_ range: NSRange) -> String {
        return (self as NSString).substring(with: range)
    }

    @inlinable func lineRange(for range: NSRange) -> NSRange {
        return (self as NSString).lineRange(for: range)
    }

    @inlinable mutating func replaceSubrange(_ range: NSRange, with replacement: String) {
        guard let range = Range(range, in: self) else {
            fatalError()
        }
        self.replaceSubrange(range, with: replacement)
    }

    // MARK: - For a concise description

    @inlinable var isNotEmpty: Bool {
        !self.isEmpty
    }

    @inlinable func index(offsetBy offset: Int) -> Index {
        return self.index(startIndex, offsetBy: offset)
    }

    @inlinable func count(characterSet set: CharacterSet) -> Int {
        return self.unicodeScalars.filter({ set.contains($0) }).count
    }

    @inlinable func contains(characterSet set: CharacterSet) -> Bool {
        return self.unicodeScalars.contains(where: { set.contains($0) })
    }

    @inlinable func isOnly(characterSet set: CharacterSet) -> Bool {
        return !self.unicodeScalars.contains(where: { !set.contains($0) })
    }


    // MARK: - For text editors

    @inlinable var monospaceCount: Int {
        let double = (utf8.count - utf16.count) / 2
        let single = count - double
        return single + double * 2
    }

    @usableFromInline static let linesRegex = try! NSRegularExpression(pattern: "^.*(?:\n|$)", options: .anchorsMatchLines)

    @inlinable func lines(range: NSRange) -> [String] {
        var lines: [String] = []
        String.linesRegex.enumerateMatches(in: self, range: range) {
            result, _, _ in
            guard let lineRange = result?.range else {
                fatalError()
            }
            lines.append(self[lineRange])
        }
        return lines
    }

    @usableFromInline typealias LineRange = (number: Int, range: NSRange)

    /// Match each line (if the line ends with a newline, match from the last newline to the end of text)
    @usableFromInline static let lineRangesRegex = try! NSRegularExpression(pattern: "^.*(?:\n|$)|(?<=\n)$", options: .anchorsMatchLines)

    @inlinable func lineRanges(range: NSRange) -> [LineRange] {
        if self.range.inRange(range) == false {
            fatalError()
        }
        if range.length == .zero {
            return lineRanges({ range.lowerBound <= $0.range.upperBound }, { range.upperBound < $0.range.upperBound })
        } else {
            return lineRanges({ range.lowerBound < $0.range.upperBound }, { range.upperBound <= $0.range.upperBound })
        }
    }

    @inlinable func lineRanges(start: Int, end: Int) -> [LineRange] {
        let result = lineRanges({ start <= $0.number }, { end <= $0.number })
        guard let s = result.first, let e = result.last, s.number == start, e.number == end else {
            return result
//            fatalError("\(result), \(start), \(end)")
        }
        return result
    }

    @inlinable func lineRanges(_ start: (LineRange) -> (Bool), _ end: (LineRange) -> (Bool)) -> [LineRange] {
        var number = 0
        var lineRanges: [LineRange] = []
        String.lineRangesRegex.enumerateMatches(in: self, range: self.range) {
            result, _, stop in
            guard let range = result?.range else {
                fatalError()
            }
            let lineRange = (number, range)
            if start(lineRange) {
                lineRanges.append(lineRange)
                stop.pointee = ObjCBool(end(lineRange))
            }
            number += 1
        }
        return lineRanges
    }

    @usableFromInline typealias TextChanges = (range: NSRange, text: String)

    @inlinable func changes(from: String) -> TextChanges {
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
