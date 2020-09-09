//
//  LineTableString.swift
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

final class LineTableString: NSMutableAttributedString {
	var lineTable: [Int: NSRange]
	private let newLine: NSRegularExpression = try! NSRegularExpression(pattern: "\n")

	override init() {
		self.lineTable = [:]
		super.init()
	}

	override init(string: String) {
		self.lineTable = [:]
		super.init(string: string)
		update(for: string.range)
	}

	required init?(coder: NSCoder) {
		fatalError()
	}

	override func replaceCharacters(in range: NSRange, with str: String) {
		super.replaceCharacters(in: range, with: str)
		update(for: range)
	}

	private func update(for range: NSRange) {
		var testRange: NSRange
		var lineNumber: Int
		var previous: Int
		if let lineTable = lineTable.filter({ NSLocationInRange(range.lowerBound, $0.value) }).first {
			testRange = NSMakeRange(lineTable.value.location, string.range.length - lineTable.value.location)
			lineNumber = lineTable.key
			previous = lineTable.value.upperBound
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
			lineTable = newTable.merging(lineTable.filter({ $0.key < minLineNumber }), uniquingKeysWith: { (new, old) in new })
		} else {
			lineTable = newTable
		}
	}

	func lineRange(for range: NSRange) -> NSRange? {
		guard let start = lineTable.filter({ NSLocationInRange(range.lowerBound, $0.value) }).first?.value,
				let end = lineTable.filter({ NSLocationInRange(range.upperBound, $0.value) }).first?.value else {
			return nil
		}
		return NSMakeRange(start.lowerBound, end.upperBound)
	}

	func lineRange(for textRange: TextRange) -> NSRange? {
		guard let start = lineTable[textRange.start.line],
				let end = lineTable[textRange.end.line] else {
			return nil
		}
		return NSMakeRange(start.lowerBound, end.upperBound)
	}

	func range(for textRange: TextRange) -> NSRange? {
		guard let start = lineTable[textRange.start.line],
				let end = lineTable[textRange.end.line] else {
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
		guard let line = lineTable.filter({ NSLocationInRange(position, $0.value) }).first else {
			return nil
		}
		return TextPosition(line: line.key, character: position - line.value.location)
	}

}
