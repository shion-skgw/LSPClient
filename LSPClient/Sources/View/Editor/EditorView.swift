//
//  EditorView.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorView: UITextView {

    private var gutterWidth: CGFloat = CGFloat.zero
    private var gutterColor: CGColor = UIColor.white.cgColor
    private var gutterEdgeColor: CGColor = UIColor.white.cgColor
    private var verticalMargin: CGFloat = CGFloat.zero

    private var lineHeight: CGFloat = CGFloat.zero
    private var lineHighlight: Bool = false
    private var lineHighlightColor: CGColor = UIColor.white.cgColor
    private var lineNumberAttribute: [NSAttributedString.Key: Any] = [:]

    init(textContainer: NSTextContainer) {
        super.init(frame: CGRect.zero, textContainer: textContainer)
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.contentMode = .redraw
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var selectedTextRange: UITextRange? {
        didSet {
            setNeedsDisplay()
        }
    }

    override func insertText(_ text: String) {
        setNeedsDisplay()
        super.insertText(text)
    }

    override func deleteBackward() {
        setNeedsDisplay()
        super.deleteBackward()
    }

}


// MARK: - Draw

extension EditorView {

    override func draw(_ rect: CGRect) {
        guard let cgContext = UIGraphicsGetCurrentContext() else {
            fatalError()
        }
        drawGutter(cgContext: cgContext)
        drawLineNumber()
        if lineHighlight {
            drawLineHighlight(cgContext: cgContext)
        }
        super.draw(rect)
    }

    private func drawGutter(cgContext: CGContext) {
        let height = max(bounds.height, contentSize.height)

        let gutterRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: gutterWidth, height: height)
        cgContext.setFillColor(gutterColor)
        cgContext.fill(gutterRect)

        let gutterEdgeRect = CGRect(x: gutterWidth, y: bounds.origin.y - 0.5, width: 0.5, height: height)
        cgContext.setFillColor(gutterEdgeColor)
        cgContext.fill(gutterEdgeRect)
    }

    private func drawLineNumber() {
        let nsString = text as NSString

        var lineNumber = 1
        var currentLineRange = nsString.lineRange(for: NSMakeRange(0, 0))
        var currentLineRect = boundingRect(forGlyphRange: currentLineRange)

        while true {
            drawLineNumber(lineNumber, currentLineRect)
            if text.range.upperBound <= currentLineRange.upperBound {
                break
            }
            lineNumber += 1
            currentLineRange = nsString.lineRange(for: NSMakeRange(currentLineRange.upperBound, 0))
            currentLineRect = boundingRect(forGlyphRange: currentLineRange)
        }

        if text.hasSuffix("\n") {
            currentLineRect.origin.y += currentLineRect.size.height
            drawLineNumber(lineNumber + 1, currentLineRect)
        }
    }

    @inline(__always)
    private func drawLineNumber(_ lineNumber: Int, _ usedRect: CGRect) {
        let number = NSAttributedString(string: "\(lineNumber)", attributes: lineNumberAttribute)
        let size = number.size()
        let x = gutterWidth - size.width - 4.0
        let y = verticalMargin + usedRect.origin.y + (lineHeight / 2.0 - size.height / 2.0)
        number.draw(at: CGPoint(x: x, y: y))
    }

    private func drawLineHighlight(cgContext: CGContext) {
        let lineRange = (text as NSString).lineRange(for: selectedRange)
        var lineRect = boundingRect(forGlyphRange: lineRange)
        lineRect.origin.x = gutterWidth + 2.0
        lineRect.origin.y += verticalMargin - 1.0
        lineRect.size.width = textContainer.size.width - 4.0
        lineRect.size.height += 2.0
        cgContext.setFillColor(lineHighlightColor)
        cgContext.fill(lineRect)
    }

    @inline(__always)
    private func boundingRect(forGlyphRange range: NSRange) -> CGRect {
        var rect = layoutManager.boundingRect(forGlyphRange: range, in: textContainer)

        // X, height adjustment of line break-only lines.
        rect.origin.x = textContainer.lineFragmentPadding
        if rect.size.width == textContainer.size.width - textContainer.lineFragmentPadding {
            rect.size.height -= lineHeight
        }
        return rect
    }

}


// MARK: - Setter

extension EditorView {

    func set(editorSetting: EditorSetting) {
        self.gutterWidth = CGFloat(editorSetting.gutterWidth)
        self.verticalMargin = CGFloat(editorSetting.verticalMargin)
        self.textContainerInset.top = self.verticalMargin
        self.textContainerInset.bottom = self.verticalMargin
        self.textContainerInset.left = self.gutterWidth
    }

    func set(codeStyle: CodeStyle) {
        let isBright = codeStyle.backgroundColor.uiColor.isBright

        self.gutterColor = codeStyle.backgroundColor.uiColor.brightness(isBright ? -0.3 : 0.3).cgColor
        self.gutterEdgeColor = codeStyle.backgroundColor.uiColor.brightness(isBright ? -0.7 : 0.7).cgColor

        self.lineHeight = codeStyle.font.uiFont.lineHeight
        self.lineHighlight = codeStyle.lineHighlight
        self.lineHighlightColor = codeStyle.backgroundColor.uiColor.brightness(isBright ? -0.2 : 0.2).cgColor
        self.lineNumberAttribute.removeAll()
        self.lineNumberAttribute[.font] = codeStyle.font.uiFont.withSize(codeStyle.font.uiFont.pointSize * 0.8)
        self.lineNumberAttribute[.foregroundColor] = codeStyle.backgroundColor.uiColor.brightness(isBright ? -0.7 : 0.7)

        // UITextView
        self.font = codeStyle.font.uiFont
        self.textColor = codeStyle.fontColor.uiColor
        self.backgroundColor = codeStyle.backgroundColor.uiColor
    }

}
