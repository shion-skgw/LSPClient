//
//  EditorView.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorView: UITextView {

    weak var controller: EditorViewController?
    private var gutterColor: CGColor
    private var gutterEdgeColor: CGColor
    private var lineHighlight: Bool
    private var lineHighlightColor: CGColor
    private var lineNumberAttribute: [NSAttributedString.Key: Any]

    override init(frame: CGRect, textContainer: NSTextContainer?) {
        // Initialize
        self.gutterColor = UIColor.white.cgColor
        self.gutterEdgeColor = UIColor.white.cgColor
        self.lineHighlight = false
        self.lineHighlightColor = UIColor.white.cgColor
        self.lineNumberAttribute = [:]
        super.init(frame: frame, textContainer: textContainer)

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

}


// MARK: - Undo / Redo

extension EditorView {

    override var undoManager: UndoManager? {
        controller?.undoManager
    }

    @objc func undo() {
        controller?.undo()
    }

    @objc func redo() {
        controller?.redo()
    }

}


// MARK: - Draw

extension EditorView {

    override func draw(_ rect: CGRect) {
        let cgContext = UIGraphicsGetCurrentContext()!
        drawGutter(cgContext)
        drawLineNumber()
        if lineHighlight {
            drawLineHighlight(cgContext)
        }
        super.draw(rect)
    }

    private func drawGutter(_ cgContext: CGContext) {
        let height = max(bounds.height, contentSize.height)

        let gutterRect = CGRect(x: bounds.origin.x, y: bounds.origin.y, width: textContainerInset.left, height: height)
        cgContext.setFillColor(gutterColor)
        cgContext.fill(gutterRect)

        let gutterEdgeRect = CGRect(x: textContainerInset.left, y: bounds.origin.y - 0.5, width: 0.5, height: height)
        cgContext.setFillColor(gutterEdgeColor)
        cgContext.fill(gutterEdgeRect)
    }

    private func drawLineNumber() {
        let nsString = text as NSString

        var lineNumber = 1
        var currentLineRange = nsString.lineRange(for: NSMakeRange(0, 0))
        var currentLineRect = layoutManager.boundingRect(forGlyphRange: currentLineRange, in: textContainer)

        while true {
            drawLineNumber(lineNumber, currentLineRect)
            if text.range.upperBound <= currentLineRange.upperBound {
                break
            }
            lineNumber += 1
            currentLineRange = nsString.lineRange(for: NSMakeRange(currentLineRange.upperBound, 0))
            currentLineRect = layoutManager.boundingRect(forGlyphRange: currentLineRange, in: textContainer)
        }

        if text.hasSuffix("\n") {
            currentLineRect.origin.y += currentLineRect.size.height
            drawLineNumber(lineNumber + 1, currentLineRect)
        }
    }

    private func drawLineNumber(_ lineNumber: Int, _ usedRect: CGRect) {
        let number = NSAttributedString(string: "\(lineNumber)", attributes: lineNumberAttribute)
        let size = number.size()
        let x = textContainerInset.left - size.width - 4.0
        let y = textContainerInset.top + usedRect.origin.y + font!.lineHeight.centeringPoint(size.height)
        number.draw(at: CGPoint(x: x, y: y))
    }

    private func drawLineHighlight(_ cgContext: CGContext) {
        let lineRange = (text as NSString).lineRange(for: selectedRange)
        var lineRect = layoutManager.boundingRect(forGlyphRange: lineRange, in: textContainer)
        lineRect.origin.x = textContainerInset.left + 2.0
        lineRect.origin.y += textContainerInset.top - 1.0
        lineRect.size.width = textContainer.size.width - 4.0
        lineRect.size.height += 2.0
        cgContext.setFillColor(lineHighlightColor)
        cgContext.fill(lineRect)
    }

}


// MARK: - Setter

extension EditorView {

    func set(editorSetting: EditorSetting) {
        let verticalMargin = editorSetting.verticalMargin
        let gutterWidth = editorSetting.gutterWidth
        self.textContainerInset.top = verticalMargin
        self.textContainerInset.bottom = verticalMargin
        self.textContainerInset.left = gutterWidth
    }

    func set(codeStyle: CodeStyle) {
        self.gutterColor = codeStyle.gutterColor.uiColor.cgColor
        self.gutterEdgeColor = codeStyle.gutterEdgeColor.uiColor.cgColor

        self.lineHighlight = codeStyle.lineHighlight
        self.lineHighlightColor = codeStyle.lineHighlightColor.uiColor.cgColor
        self.lineNumberAttribute.removeAll()
        self.lineNumberAttribute[.font] = codeStyle.font.uiFont.withSize(codeStyle.lineNumberSize)
        self.lineNumberAttribute[.foregroundColor] = codeStyle.lineNumberColor.uiColor

        // UITextView
        self.font = codeStyle.font.uiFont
        self.textColor = codeStyle.fontColor.text.uiColor
        self.backgroundColor = codeStyle.backgroundColor.uiColor
    }

}
