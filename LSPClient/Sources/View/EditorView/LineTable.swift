//
//  LineTable.swift
//  LSPClient
//
//  Created by Shion on 2020/08/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

///
/// Line range table
///
final class LineTable {

    struct Context {
        let lineRange: NSRange
        let indentLevel: Int
    }

    /// Line range table (Key: Zero based line number, Value: Line range)
    var table: [Int: NSRange]
    /// Text contents
    weak var content: NSMutableAttributedString?
    /// Newline character
    private let newLine: NSRegularExpression = try! NSRegularExpression(pattern: "\n")

    ///
    /// Initialize
    ///
    /// - Parameter content: Text contents
    ///
    init(content: NSMutableAttributedString) {
        self.table = [:]
        self.content = content
        update(for: content.string.range)
    }

    ///
    /// Update line range table
    ///
    /// - Parameter range: Update range
    ///
    func update(for range: NSRange) {
        guard let string = content?.string else {
            return
        }

        // Update start position
        var testRange: NSRange
        var lineNumber: Int
        var previousLineEnd: Int
        if let lineRange = table.first(where: { NSLocationInRange(range.lowerBound, $0.value) }) {
            testRange = NSMakeRange(lineRange.value.location, string.length - lineRange.value.location)
            lineNumber = lineRange.key
            previousLineEnd = lineRange.value.upperBound
        } else {
            testRange = string.range
            lineNumber = 0
            previousLineEnd = 0
        }

        // Create a new line range table
        var newTable: [Int: NSRange] = [:]
        newLine.enumerateMatches(in: string, range: testRange) {
            (result, _, _) in
            guard let currentLineEnd = result?.range.upperBound else {
                return
            }
            newTable[lineNumber] = NSMakeRange(previousLineEnd, currentLineEnd - previousLineEnd)
            lineNumber += 1
            previousLineEnd = currentLineEnd
        }
        if previousLineEnd < string.range.upperBound {
            newTable[lineNumber] = NSMakeRange(previousLineEnd, string.range.upperBound - previousLineEnd)
        }

        // Merge line range table
        if let minLineNumber = newTable.min(by: { $0.key < $1.key })?.key, 0 < minLineNumber {
            table = newTable.merging(table.filter({ $0.key < minLineNumber }), uniquingKeysWith: { (new, old) in new })
        } else {
            table = newTable
        }
    }

    ///
    /// Returns line range
    ///
    /// - Parameter range: NS characters range
    /// - Returns        : NS line range
    ///
    func lineRange(for range: NSRange) -> NSRange? {
        guard let start = table.first(where: { NSLocationInRange(range.lowerBound, $0.value) })?.value,
                let end = table.first(where: { NSLocationInRange(range.upperBound, $0.value) })?.value else {
            return nil
        }
        return NSMakeRange(start.lowerBound, end.upperBound)
    }

    ///
    /// Returns line range
    ///
    /// - Parameter range: LSP characters range
    /// - Returns        : NS line range
    ///
    func lineRange(for textRange: TextRange) -> NSRange? {
        guard let start = table[textRange.start.line],
                let end = table[textRange.end.line] else {
            return nil
        }
        return NSMakeRange(start.lowerBound, end.upperBound)
    }

    ///
    /// Convert characters range
    ///
    /// - Parameter textRange: LSP characters range
    /// - Returns            : NS characters range
    ///
    func range(for textRange: TextRange) -> NSRange? {
        guard let start = table[textRange.start.line],
                let end = table[textRange.end.line] else {
            return nil
        }
        let location = start.location + textRange.start.character
        let length = end.location - start.location + textRange.end.character
        return NSMakeRange(location, length)
    }

    ///
    /// Convert characters range
    ///
    /// - Parameter range: NS characters range
    /// - Returns        : LSP characters range
    ///
    func range(for range: NSRange) -> TextRange? {
        guard let start = position(for: range.lowerBound),
                let end = position(for: range.upperBound) else {
            return nil
        }
        return TextRange(start: start, end: end)
    }

    ///
    /// Convert characters position
    ///
    /// - Parameter position: NS characters position
    /// - Returns           : LSP characters position
    ///
    func position(for position: Int) -> TextPosition? {
        guard let line = table.first(where: { NSLocationInRange(position, $0.value) }) else {
            return nil
        }
        return TextPosition(line: line.key, character: position - line.value.location)
    }

}
