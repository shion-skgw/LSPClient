//
//  EditorTextStorage.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.NSTextStorage

final class EditorTextStorage: NSTextStorage {

    let content: NSMutableAttributedString
    weak var syntaxManager: SyntaxManager?
    private(set) var textAttribute: [NSAttributedString.Key: Any]
    private(set) var highlightAttribute: [SyntaxType: [NSAttributedString.Key: Any]]

    override var string: String {
        content.string
    }

    override init() {
        self.content = NSMutableAttributedString()
        self.syntaxManager = nil
        self.textAttribute = [:]
        self.highlightAttribute = [:]
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func attributes(at location: Int, effectiveRange range: NSRangePointer?) -> [NSAttributedString.Key : Any] {
        content.attributes(at: location, effectiveRange: range)
    }

    override func replaceCharacters(in range: NSRange, with str: String) {
        beginEditing()
        content.replaceCharacters(in: range, with: str)
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
        let range = syntaxManager?.highlightRange(text: string, range: editedRange) ?? editedRange
        setAttributes(textAttribute, range: range)
        applySyntaxHighlight(range)
        super.processEditing()
    }

    private func applySyntaxHighlight(_ range: NSRange) {
        syntaxManager?.highlight(text: string, range: range).forEach() {
            guard let attribute = self.highlightAttribute[$0.type] else {
                fatalError()
            }
            self.content.addAttributes(attribute, range: $0.range)
        }
    }

}

extension EditorTextStorage {

    func set(codeStyle: CodeStyle) {
        fontSetting(codeStyle)
        tabSetting(codeStyle)
        highlightSetting(codeStyle)
    }

    private func fontSetting(_ codeStyle: CodeStyle) {
        self.textAttribute.removeAll()
        self.textAttribute[.font] = codeStyle.font.uiFont
        self.textAttribute[.foregroundColor] = codeStyle.fontColor.text.uiColor
    }

    private func tabSetting(_ codeStyle: CodeStyle) {
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops?.removeAll()
        let baseTabWidth = " ".size(withAttributes: self.textAttribute).width * CGFloat(codeStyle.tabSize)
        for i in 1 ... 100 {
            let textTab = NSTextTab(textAlignment: .left, location: baseTabWidth * CGFloat(i))
            paragraphStyle.addTabStop(textTab)
        }
        self.textAttribute[.paragraphStyle] = paragraphStyle
    }

    private func highlightSetting(_ codeStyle: CodeStyle) {
        self.highlightAttribute.removeAll()
        self.highlightAttribute[.keyword] = [
            .font: codeStyle.font.uiFont,
            .foregroundColor: codeStyle.fontColor.keyword.uiColor,
        ]
        self.highlightAttribute[.function] = [
            .font: codeStyle.font.uiFont,
            .foregroundColor: codeStyle.fontColor.function.uiColor,
        ]
        self.highlightAttribute[.number] = [
            .font: codeStyle.font.uiFont,
            .foregroundColor: codeStyle.fontColor.number.uiColor,
        ]
        self.highlightAttribute[.string] = [
            .font: codeStyle.font.uiFont,
            .foregroundColor: codeStyle.fontColor.string.uiColor,
        ]
        self.highlightAttribute[.comment] = [
            .font: codeStyle.font.uiFont,
            .foregroundColor: codeStyle.fontColor.comment.uiColor,
        ]
    }

}
