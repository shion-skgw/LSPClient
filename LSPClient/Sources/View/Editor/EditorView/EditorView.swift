//
//  EditorView.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorView: UITextView {

    private var gutterColor: CGColor
    private var gutterEdgeColor: CGColor
    private var lineHighlightColor: CGColor
    private var lineNumberAttribute: [NSAttributedString.Key: Any]

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        // Initialize
        self.gutterColor = UIColor.white.cgColor
        self.gutterEdgeColor = UIColor.white.cgColor
        self.lineHighlightColor = UIColor.white.cgColor
        self.lineNumberAttribute = [:]
        super.init(frame: frame, textContainer: textContainer)

        self.textContainerInset.top = EditorViewController.verticalMargin
        self.textContainerInset.bottom = EditorViewController.verticalMargin
        self.textContainerInset.left = EditorViewController.gutterWidth

        // UIView setting
        self.contentMode = .redraw

        // UITextInputTraits setting
        self.autocapitalizationType = .none
        self.autocorrectionType = .no
        self.spellCheckingType = .no
        self.smartQuotesType = .no
        self.smartDashesType = .no
        self.smartInsertDeleteType = .no
        self.keyboardType = .asciiCapable
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override var selectedTextRange: UITextRange? {
        didSet {
            setNeedsDisplay()
        }
    }

    override var selectedRange: NSRange {
        didSet {
            setNeedsDisplay()
        }
    }

    override func insertText(_ text: String) {
        super.insertText(text)
        setNeedsDisplay()
    }

    override func deleteBackward() {
        super.deleteBackward()
        setNeedsDisplay()
    }

    func replaceText(in range: NSRange, with replacement: String, selected: Bool) {
        textStorage.replaceCharacters(in: range, with: replacement)
        if selected {
            selectedRange = NSMakeRange(range.location, replacement.length)
        } else {
            selectedRange = NSMakeRange(range.location + replacement.length, .zero)
        }
    }

}


// MARK: - Draw

extension EditorView {

    override func draw(_ rect: CGRect) {
        let cgContext = UIGraphicsGetCurrentContext()!
        drawGutter(cgContext)
        drawLineNumber(rect)
        drawLineHighlight(cgContext)
        super.draw(rect)
    }

    private func drawGutter(_ cgContext: CGContext) {
        let gutterRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: textContainerInset.left, height: bounds.height)
        cgContext.setFillColor(gutterColor)
        cgContext.fill(gutterRect)

        let gutterEdgeRect = CGRect(x: textContainerInset.left, y: bounds.origin.y - 0.5, width: 0.5, height: bounds.height)
        cgContext.setFillColor(gutterEdgeColor)
        cgContext.fill(gutterEdgeRect)
    }

    private func drawLineNumber(_ rect: CGRect) {
        var lineNumber = Int.zero
        var lineRect = CGRect.zero

        text.lineRanges(range: layoutManager.glyphRange(forBoundingRect: rect, in: textContainer)).forEach() {
            lineNumber = $0.number + 1
            lineRect = layoutManager.boundingRect(forGlyphRange: $0.range, in: textContainer)
            drawLineNumber(lineNumber, lineRect)
        }

        if text.hasSuffix("\n") {
            lineRect.origin.y += lineRect.size.height
            drawLineNumber(lineNumber + 1, lineRect)
        }
    }

    private func drawLineNumber(_ lineNumber: Int, _ usedRect: CGRect) {
        let number = NSAttributedString(string: "\(lineNumber)", attributes: lineNumberAttribute)
        let size = number.size()
        let x = textContainerInset.left - size.width - 4
        let y = textContainerInset.top + usedRect.origin.y + font!.lineHeight.centeringPoint(size.height)
        number.draw(at: CGPoint(x: x, y: y))
    }

    private func drawLineHighlight(_ cgContext: CGContext) {
        let lineRange = text.lineRange(for: selectedRange)
        var lineRect = layoutManager.boundingRect(forGlyphRange: lineRange, in: textContainer)
        lineRect.origin.x = textContainerInset.left + 2
        lineRect.origin.y += textContainerInset.top - 1
        lineRect.size.width = textContainer.size.width - 4
        lineRect.size.height += 2
        cgContext.setFillColor(lineHighlightColor)
        cgContext.fill(lineRect)
    }

}


// MARK: - Setter

extension EditorView {

    func set(codeStyle: CodeStyle) {
        // Gutter setting
        self.gutterColor = codeStyle.backgroundColor.cgColor
        self.gutterEdgeColor = codeStyle.edgeColor.cgColor
        self.lineNumberAttribute.removeAll()
        self.lineNumberAttribute[.font] = codeStyle.font.withSize(codeStyle.lineNumberSize)
        self.lineNumberAttribute[.foregroundColor] = codeStyle.edgeColor

        // Line highlight setting
        self.lineHighlightColor = codeStyle.highlightColor.cgColor

        // UITextView
        self.font = codeStyle.font.uiFont
        self.textColor = codeStyle.fontColor.text.uiColor
        self.backgroundColor = codeStyle.backgroundColor
        self.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white
    }

}
