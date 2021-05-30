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
    private(set) var diagnosticAttribute: [DiagnosticSeverity: [NSAttributedString.Key: Any]]

    override var string: String {
        content.string
    }

    override init() {
        self.content = NSMutableAttributedString()
        self.syntaxManager = nil
        self.textAttribute = [:]
        self.highlightAttribute = [:]
        self.diagnosticAttribute = [:]
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
        edited([.editedCharacters, .editedAttributes], range: range, changeInLength: str.length - range.length)
        endEditing()
    }

    override func setAttributes(_ attrs: [NSAttributedString.Key : Any]?, range: NSRange) {
        beginEditing()
        content.setAttributes(attrs, range: range)
        edited(.editedAttributes, range: range, changeInLength: 0)
        endEditing()
    }

    override func processEditing() {
        let lineRange = string.lineRange(for: editedRange)
        setAttributes(textAttribute, range: lineRange)
        applySyntaxHighlight(lineRange)
        super.processEditing()
    }

    private func applySyntaxHighlight(_ range: NSRange) {
        guard let syntaxManager = self.syntaxManager else {
            return
        }
        syntaxManager.highlight(text: string, range: range).forEach() {
            guard let attribute = self.highlightAttribute[$0.type] else {
                fatalError()
            }
            self.content.addAttributes(attribute, range: $0.range)
        }
    }

    func applyDiagnostic(diagnostic: [NSRange: DiagnosticSeverity]) {
        self.content.removeAttribute(.underlineStyle, range: string.range)
        diagnostic.forEach() {
            guard let attribute = self.diagnosticAttribute[$0.value] else {
                fatalError()
            }
            guard string.range.inRange($0.key) else {
                print("\(string.range) vs \($0.key) aaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaaa")
                return
            }
            self.content.addAttributes(attribute, range: $0.key)
        }
    }

}

extension EditorTextStorage {

    func set(codeStyle: CodeStyle) {
        textSetting(codeStyle)
        highlightSetting(codeStyle)
        diagnosticSetting(codeStyle)
    }

    private func textSetting(_ codeStyle: CodeStyle) {
        // Text attribute setting
        self.textAttribute.removeAll()
        self.textAttribute[.font] = codeStyle.font.uiFont
        self.textAttribute[.foregroundColor] = codeStyle.fontColor.text.uiColor

        // Tab setting
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.tabStops?.removeAll()
        paragraphStyle.defaultTabInterval = " ".size(withAttributes: self.textAttribute).width * CGFloat(codeStyle.tabSize)
        self.textAttribute[.paragraphStyle] = paragraphStyle
    }

    private func highlightSetting(_ codeStyle: CodeStyle) {
        self.highlightAttribute.removeAll()
        self.highlightAttribute[.keyword] = [
            .foregroundColor: codeStyle.fontColor.keyword.uiColor,
        ]
        self.highlightAttribute[.function] = [
            .foregroundColor: codeStyle.fontColor.function.uiColor,
        ]
        self.highlightAttribute[.number] = [
            .foregroundColor: codeStyle.fontColor.number.uiColor,
        ]
        self.highlightAttribute[.string] = [
            .foregroundColor: codeStyle.fontColor.string.uiColor,
        ]
        self.highlightAttribute[.comment] = [
            .foregroundColor: codeStyle.fontColor.comment.uiColor,
        ]
    }

    private func diagnosticSetting(_ codeStyle: CodeStyle) {
        self.diagnosticAttribute.removeAll()
        self.diagnosticAttribute[.error] = [
            .underlineStyle: NSUnderlineStyle.double.rawValue,
            .underlineColor: UIColor.red
        ]
        self.diagnosticAttribute[.warning] = [
            .underlineStyle: NSUnderlineStyle.single.rawValue,
            .underlineColor: UIColor.yellow
        ]
        self.diagnosticAttribute[.information] = [
            .underlineStyle: NSUnderlineStyle.patternDash.rawValue,
            .underlineColor: UIColor.green
        ]
        self.diagnosticAttribute[.hint] = [
            .underlineStyle: NSUnderlineStyle.patternDot.rawValue,
            .underlineColor: UIColor.green
        ]
    }

}
