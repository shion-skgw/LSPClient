//
//  TextStorage.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.NSTextStorage

final class TextStorage: NSTextStorage {

    let lineTable: LineTable
    private let content: NSMutableAttributedString
    private var tokens: [Token]
    private var textAttribute: [NSAttributedString.Key: Any]

    override var string: String {
        return content.string
    }

    override init() {
        self.content = NSMutableAttributedString()
        self.lineTable = LineTable(content: self.content)
        self.tokens = []
        self.textAttribute = [:]
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        return content.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        lineTable.replaceCharacters(in: range, with: str)
        edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.count - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        content.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    override func processEditing() {
        let lineRange = (string as NSString).lineRange(for: editedRange)
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

extension TextStorage {

    func set(string: String) {
        self.lineTable.replaceCharacters(in: self.string.range, with: string)
        self.applySyntaxHighlight(self.string.range) // TODO: 必要か確認する
    }

    func set(tokens: [Token]) {
        self.tokens.removeAll()
        self.tokens.append(contentsOf: tokens.sorted(by: { !$0.isMultipleLines && $1.isMultipleLines }))
        self.applySyntaxHighlight(self.string.range)
    }

    func set(codeStyle: CodeStyle) {
        // Font settings
        self.textAttribute.removeAll()
        self.textAttribute[.font] = codeStyle.font.uiFont
        self.textAttribute[.foregroundColor] = codeStyle.fontColor.uiColor

        // Tab settings
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops?.removeAll()
        let baseTabWidth = " ".size(withAttributes: self.textAttribute).width * CGFloat(codeStyle.tabSize)
        for i in 1 ... 100 {
            let textTab = NSTextTab(textAlignment: .left, location: baseTabWidth * CGFloat(i))
            paragraphStyle.addTabStop(textTab)
        }
        self.textAttribute[.paragraphStyle] = paragraphStyle
    }

}
