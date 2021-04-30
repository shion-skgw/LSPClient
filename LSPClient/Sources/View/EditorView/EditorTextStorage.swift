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
    private(set) weak var syntaxManager: SyntaxManager?
    private(set) var textAttribute: [NSAttributedString.Key: Any]
    private(set) var highlightAttribute: [SyntaxType: [NSAttributedString.Key: Any]]

    override var string: String {
        content.string
    }

    var highlightRange: NSRange {
        guard let syntaxManager = self.syntaxManager else {
            return editedRange
        }

        let tampRange = NSMakeRange(max(0, editedRange.location - 1), editedRange.length + 1)
        let fullRange = string.range

        if let range = Range(NSIntersectionRange(tampRange, fullRange), in: string) {
            let text = string[range]
            let isNeedRefresh = syntaxManager.multipleLineSymbol.contains(where: { text.contains($0) })
            return isNeedRefresh ? fullRange : (string as NSString).lineRange(for: editedRange)

        } else {
            return (string as NSString).lineRange(for: editedRange)
        }
    }

    init(syntaxManager: SyntaxManager?) {
        self.content = NSMutableAttributedString()
        self.syntaxManager = syntaxManager
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
        let range = highlightRange
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
        var attribute: [NSAttributedString.Key: Any] = [.font: codeStyle.font.uiFont]

        attribute[.foregroundColor] = codeStyle.fontColor.keyword.uiColor
        self.highlightAttribute[.keyword] = attribute

        attribute[.foregroundColor] = codeStyle.fontColor.function.uiColor
        self.highlightAttribute[.function] = attribute

        attribute[.foregroundColor] = codeStyle.fontColor.number.uiColor
        self.highlightAttribute[.number] = attribute

        attribute[.foregroundColor] = codeStyle.fontColor.string.uiColor
        self.highlightAttribute[.string] = attribute

        attribute[.foregroundColor] = codeStyle.fontColor.comment.uiColor
        self.highlightAttribute[.comment] = attribute
    }

}
