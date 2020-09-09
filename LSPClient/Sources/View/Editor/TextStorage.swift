//
//  TextStorage.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.NSTextStorage

final class TextStorage: NSTextStorage {

	private var lineTableString: LineTableString
	private var tokens: [Token]
	private var textAttribute: [NSAttributedString.Key: Any]

	override var string: String {
		return lineTableString.string
	}

	init(tokens: [Token]) {
		self.lineTableString = LineTableString()
		self.tokens = tokens.sorted(by: { !$0.isMultipleLines && $1.isMultipleLines })
		self.textAttribute = [NSAttributedString.Key: Any]()
		super.init()
	}

	required init?(coder: NSCoder) {
		fatalError("init(coder:) has not been implemented")
	}

	override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
		return lineTableString.attributes(at: location, effectiveRange: range)
	}

	override func replaceCharacters(in range: NSRange, with str: String) {
		beginEditing()
		lineTableString.replaceCharacters(in: range, with: str)
		edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.count - range.length)
		endEditing()
	}

	override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
		beginEditing()
		lineTableString.setAttributes(attrs, range: range)
		edited(.editedAttributes, range: range, changeInLength: 0)
		endEditing()
	}

	override func processEditing() {
		guard let lineRange = lineTableString.lineRange(for: editedRange) else {
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
