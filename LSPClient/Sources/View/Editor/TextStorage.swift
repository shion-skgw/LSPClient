//
//  TextStorage.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.NSTextStorage

final class TextStorage: NSTextStorage {

	private var attributedString: NSMutableAttributedString
	private var lineTable: LineTable
	private var tokens: [Token]
	private var textAttribute: [NSAttributedString.Key: Any]

	override var string: String {
		return attributedString.string
	}

	init(tokens: [Token]) {
		self.attributedString = NSMutableAttributedString()
		self.lineTable = LineTable(string: self.attributedString)
		self.tokens = tokens.sorted(by: { !$0.isMultipleLines && $1.isMultipleLines })
		self.textAttribute = [NSAttributedString.Key: Any]()
		super.init()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
		return attributedString.attributes(at: location, effectiveRange: range)
	}

	override func replaceCharacters(in range: NSRange, with str: String) {
		beginEditing()
		attributedString.replaceCharacters(in: range, with: str)
		lineTable.update(for: range)
		edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.count - range.length)
		endEditing()
	}

	override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
		beginEditing()
		attributedString.setAttributes(attrs, range: range)
		edited(.editedAttributes, range: range, changeInLength: 0)
		endEditing()
	}

	override func processEditing() {
		guard let lineRange = lineTable.lineRange(for: editedRange) else {
			return
		}
		setAttributes(textAttribute, range: lineRange)
		applySyntaxHighlight(lineRange)
		super.processEditing()
	}

	private func applySyntaxHighlight(_ range: NSRange) {
		for token in tokens {
			token.regex.enumerateMatches(in: string, options: [], range: token.isMultipleLines ? string.range : range) {
				[unowned self, token] (result, _, _) in
				guard let range = result?.range else {
					return
				}
				self.addAttributes(token.textAttribute, range: range)
			}
		}
	}

}
