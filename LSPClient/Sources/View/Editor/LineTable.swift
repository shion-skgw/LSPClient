//
//  LineTable.swift
//  LSPClient
//
//  Created by Shion on 2020/08/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

extension String {
	var range: NSRange {
		NSMakeRange(0, utf16.count)
	}
}

final class LineTable {
	var table: [Int: NSRange]
	weak var content: NSMutableAttributedString?
	private let newLine: NSRegularExpression = try! NSRegularExpression(pattern: "\n")

	init(string: NSMutableAttributedString) {
		self.table = [:]
		self.content = string
		update(for: string.string.range)
	}

	func replaceCharacters(in range: NSRange, with str: String) {
		content?.replaceCharacters(in: range, with: str)
		update(for: range)
	}

	func update(for range: NSRange) {
		guard let string = content?.string else {
			return
		}

		var testRange: NSRange
		var lineNumber: Int
		var previous: Int
		if let lineRange = table.filter({ NSLocationInRange(range.lowerBound, $0.value) }).first {
			testRange = NSMakeRange(lineRange.value.location, string.range.length - lineRange.value.location)
			lineNumber = lineRange.key
			previous = lineRange.value.upperBound
		} else {
			testRange = string.range
			lineNumber = 0
			previous = 0
		}

		var newTable: [Int: NSRange] = [:]
		newLine.enumerateMatches(in: string, options: [], range: testRange) {
			(result, _, _) in
			guard let current = result?.range.upperBound else {
				return
			}
			newTable[lineNumber] = NSMakeRange(previous, current - previous)
			lineNumber += 1
			previous = current
		}
		if previous < string.range.upperBound {
			newTable[lineNumber] = NSMakeRange(previous, string.range.upperBound - previous)
		}
		if let minLineNumber = newTable.min(by: { $0.key < $1.key })?.key, 0 < minLineNumber {
			table = newTable.merging(table.filter({ $0.key < minLineNumber }), uniquingKeysWith: { (new, old) in new })
		} else {
			table = newTable
		}
	}

	func lineRange(for range: NSRange) -> NSRange? {
		guard let start = table.filter({ NSLocationInRange(range.lowerBound, $0.value) }).first?.value,
				let end = table.filter({ NSLocationInRange(range.upperBound, $0.value) }).first?.value else {
			return nil
		}
		return NSMakeRange(start.lowerBound, end.upperBound)
	}

	func lineRange(for textRange: TextRange) -> NSRange? {
		guard let start = table[textRange.start.line],
				let end = table[textRange.end.line] else {
			return nil
		}
		return NSMakeRange(start.lowerBound, end.upperBound)
	}

	func range(for textRange: TextRange) -> NSRange? {
		guard let start = table[textRange.start.line],
				let end = table[textRange.end.line] else {
			return nil
		}
		let location = start.location + textRange.start.character
		let length = end.location - start.location + textRange.end.character
		return NSMakeRange(location, length)
	}

	func range(for range: NSRange) -> TextRange? {
		guard let start = position(for: range.lowerBound),
				let end = position(for: range.upperBound) else {
			return nil
		}
		return TextRange(start: start, end: end)
	}

	func position(for position: Int) -> TextPosition? {
		guard let line = table.filter({ NSLocationInRange(position, $0.value) }).first else {
			return nil
		}
		return TextPosition(line: line.key, character: position - line.value.location)
	}

}
