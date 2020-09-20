//
//  LayoutManager.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.NSLayoutManager

final class LayoutManager: NSLayoutManager {

    private let invisibles: [String: NSRegularExpression] = [
        "\u{21B5}": try! NSRegularExpression(pattern: "\n", options: []),       // "↵" New line
        "\u{226B}": try! NSRegularExpression(pattern: "\t", options: []),       // "≫" Tab
        "\u{22C5}": try! NSRegularExpression(pattern: "\u{0020}", options: []), // "⋅" Space
        "\u{25A1}": try! NSRegularExpression(pattern: "\u{3000}", options: []), // "□" Full space
    ]

    private var invisiblesAttribute: [NSAttributedString.Key: Any] = [:]
    private var lineHeight: CGFloat = CGFloat.zero
    private var showInvisibles: Bool = false
    private var gutterWidth: CGFloat = CGFloat.zero
    private var verticalMargin: CGFloat = CGFloat.zero

    override init() {
        super.init()
        self.usesFontLeading = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func drawBackground(forGlyphRange glyphsToShow: NSRange, at origin: CGPoint) {
        super.drawBackground(forGlyphRange: glyphsToShow, at: origin)

        guard showInvisibles, let text = textStorage?.string else {
            return
        }

        for invisible in invisibles {
            let char = invisible.key
            let charSize = char.size(withAttributes: invisiblesAttribute)

            invisible.value.enumerateMatches(in: text, options: [], range: glyphsToShow) {
                [unowned self, char, charSize] (result, _, _) in
                guard let range = result?.range else {
                    return
                }

                let position = range.upperBound - 1
                let rect = lineFragmentRect(forGlyphAt: position, effectiveRange: nil)
                var point = location(forGlyphAt: position)
                point.x += rect.origin.x + self.gutterWidth
                point.y = rect.origin.y + self.verticalMargin + (self.lineHeight / 2.0 - charSize.height / 2.0)
                char.draw(at: point, withAttributes: self.invisiblesAttribute)
            }
        }
    }

}

extension LayoutManager {

    func set(editorSetting: EditorSetting) {
        self.gutterWidth = CGFloat(editorSetting.gutterWidth)
        self.verticalMargin = CGFloat(editorSetting.verticalMargin)
    }

    func set(codeStyle: CodeStyle) {
        self.invisiblesAttribute.removeAll()
        self.invisiblesAttribute[.font] = codeStyle.font.uiFont
        self.invisiblesAttribute[.foregroundColor] = codeStyle.invisiblesFontColor.uiColor
        self.lineHeight = codeStyle.font.uiFont.lineHeight
        self.showInvisibles = codeStyle.showInvisibles
    }

}
