//
//  EditorViewController.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController {
    private var viewModel: EditorViewModel!
    /// EditorView
    private(set) weak var editorView: EditorView!
    /// EditorTextStorage
    private(set) weak var textStorage: EditorTextStorage!
    /// EditorLayoutManager
    private(set) weak var layoutManager: EditorLayoutManager!
    /// SyntaxManager
    private(set) weak var syntaxManager: SyntaxManager?

    /// CompletionViewController
    private(set) weak var completion: CompletionViewController!
    private var isShownCompletion: Bool {
        self.completion?.view.isHidden == false
    }

    /// HoverViewController
    private(set) weak var hover: HoverViewController!
    private var isShownHover: Bool {
        self.hover?.view.isHidden == false
    }

    /// SignatureHelpViewController
    private(set) weak var signatureHelp: SignatureHelpViewController!
    private var isShownSignatureHelp: Bool {
        self.signatureHelp?.view.isHidden == false
    }

    private var contentText: String {
        self.editorView.text
    }
    private var selectedRange: NSRange {
        get {
            self.editorView.selectedRange
        }
        set {
            self.editorView.selectedRange = newValue
        }
    }


    private let serverCapability = ServerCapability.load()

    static let gutterWidth: CGFloat = 40.0
    static let verticalMargin: CGFloat = 4.0

    override var undoManager: UndoManager? {
        self.editorView.undoManager
    }

    var uri: DocumentUri = .bluff

    override func loadView() {
        // SyntaxManager
        let syntaxManager = SyntaxManager.load(fileExtension: uri.pathExtension)
        self.syntaxManager = syntaxManager

        // EditorViewModel
        let viewModel = EditorViewModel()
        viewModel.controller = self
        viewModel.syntaxManager = syntaxManager
        self.viewModel = viewModel

        // TextContainer
        let textContainer = NSTextContainer()
        textContainer.lineBreakMode = .byCharWrapping

        // LayoutManager
        let layoutManager = EditorLayoutManager()
        layoutManager.addTextContainer(textContainer)
        self.layoutManager = layoutManager

        // TextStorage
        let textStorage = EditorTextStorage()
        textStorage.syntaxManager = syntaxManager
        textStorage.addLayoutManager(layoutManager)
        self.textStorage = textStorage

        // EditorView
        let editorView = EditorView(frame: .zero, textContainer: textContainer)
        editorView.delegate = self
        self.editorView = editorView
        self.view = editorView

        refreshCodeStyle()
    }

    override func viewDidLoad() {
        guard let text = try? WorkspaceManager.shared.open(uri: uri) else {
            let title = "aaaa"
            let message = ""
            present(UIAlertController.anyAlert(title: title, message: message), animated: true)
            return
        }

        textStorage.replaceCharacters(in: contentText.range, with: text)
        viewModel.sendDidOpen(editorView)

        // Notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
        notificationCenter.addObserver(self, selector: #selector(refreshDiagnostics), name: .didReceiveDiagnostics, object: nil)
    }

    @objc private func refreshDiagnostics(_ notification: Notification) {
        guard uri == notification.userInfoValue as? DocumentUri,
                let diagnostics = Diagnosis.load()[uri], diagnostics.isNotEmpty else {
            return
        }
        let aa = diagnostics.map({ (NSRange($0.range, in: contentText), $0.severity ?? .information) })
        textStorage.applyDiagnostic(diagnostic: aa)
        editorView.setNeedsDisplay()
    }

    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()
        self.tabSize = codeStyle.tabSize
        self.indentCharacter = codeStyle.useHardTab ? .tab : .space
        self.editorView.set(codeStyle: codeStyle)
        self.textStorage.set(codeStyle: codeStyle)
        self.layoutManager.set(codeStyle: codeStyle)
    }

    private var tabSize: Int = 0
    private var indentCharacter: String = ""
    private var indent: String {
        self.indentCharacter == .tab ? .tab : String(repeating: self.indentCharacter, count: self.tabSize)
    }

    private var beforeInputText: String = ""
    private var isNeedCommitChanges: Bool = false
    private var isNeedCompletion: Bool = false
    private var isNeedSignatureHelp: Bool = false

    override var keyCommands: [UIKeyCommand]? {
        var commands: [UIKeyCommand] = [
            // Deindent
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: .shift, action: #selector(didInput)),
        ]
        if syntaxManager != nil {
            commands.append(contentsOf: [
                // Compilation
                UIKeyCommand(input: UIKeyCommand.inputSlash, modifierFlags: .command, action: #selector(didInput)),
                // Move caret to previous
                UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .alternate, action: #selector(didInput)),
                // Move caret to next
                UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .alternate, action: #selector(didInput)),
            ])
        }
        if isShownCompletion {
            commands.append(contentsOf: [
                // Move completion item to previous
                UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(didInput)),
                // Move completion item to next
                UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(didInput)),
            ])
        } else if serverCapability.completion.isSupport {
            commands.append(contentsOf: [
                // Invoke completion
                UIKeyCommand(input: UIKeyCommand.inputSpace, modifierFlags: .alternate, action: #selector(didInput)),
            ])
        }
        return commands
    }

    @objc private func didInput(command: UIKeyCommand) {
        switch (command.input, command.modifierFlags) {
        case (UIKeyCommand.inputTab, .shift):
            deindent()

        case (UIKeyCommand.inputSlash, .command):
            toggleComment()

        case (UIKeyCommand.inputSpace, .alternate):
            viewModel.sendDidChange(editorView)
            viewModel.sendCompletion(editorView, trigger: nil)

        case (UIKeyCommand.inputLeftArrow, _):
            moveCaretPrevious()

        case (UIKeyCommand.inputRightArrow, _):
            moveCaretNext()

        case (UIKeyCommand.inputUpArrow, _):
            completion.moveSelection(direction: -)

        case (UIKeyCommand.inputDownArrow, _):
            completion.moveSelection(direction: +)

        default:
            fatalError()
        }
    }

    private func moveCaretPrevious() {
        guard let syntaxManager = self.syntaxManager else {
            fatalError()
        }
        let lineRange = contentText.lineRange(for: selectedRange)
        if let previousWordRange = syntaxManager
                .wordRanges(text: contentText, range: lineRange)
                .last(where: { $0.lowerBound < selectedRange.lowerBound }) {
            selectedRange = NSMakeRange(previousWordRange.lowerBound, .zero)
        } else {
            selectedRange = NSMakeRange(max(lineRange.lowerBound - 1, 0), .zero)
        }
    }

    private func moveCaretNext() {
        guard let syntaxManager = self.syntaxManager else {
            fatalError()
        }
        let lineRange = contentText.lineRange(for: selectedRange)
        if let nextWordRange = syntaxManager
                .wordRanges(text: contentText, range: lineRange)
                .first(where: { selectedRange.upperBound < $0.upperBound }) {
            selectedRange = NSMakeRange(nextWordRange.upperBound, .zero)
        } else {
            selectedRange = NSMakeRange(lineRange.upperBound, .zero)
        }
    }

}


// MARK: - UITextViewDelegate

extension EditorViewController: UITextViewDelegate {

    func textView(_: UITextView, shouldChangeTextIn range: NSRange, replacementText inputText: String) -> Bool {
        if isShownCompletion {
            if viewModel.needCommitCompletion(inputText) {
                commitCompletion()
                return false
            } else {
                completion.willInput(range: range, text: inputText)
                return true
            }

        } else {
            if needRegisterUndo(inputText) {
                registerUndo()
            }
            isNeedCompletion = viewModel.needCompletion(inputText)
            isNeedSignatureHelp = viewModel.needSignatureHelp(inputText)
            isNeedCommitChanges = isNeedCompletion
                || isNeedSignatureHelp
                || viewModel.needCommitChanges(current: inputText, last: beforeInputText)
            beforeInputText = inputText
            return shouldChange(range, inputText)
        }
    }

    func textViewDidChangeSelection(_: UITextView) {
        guard let undoManager = self.undoManager else {
            fatalError()
        }
        if isShownCompletion && !completion.completionRange.inRange(selectedRange) {
            completion.hide()
        }
        if isShownHover {
            hover.hide()
        }
        if isShownSignatureHelp {
            signatureHelp.hide()
        }
        if isNeedCommitChanges || undoManager.isUndoing || undoManager.isRedoing {
            viewModel.sendDidChange(editorView)
        }
        if isNeedCompletion {
            viewModel.sendCompletion(editorView, trigger: beforeInputText)
        } else if isNeedSignatureHelp {
            viewModel.sendSignatureHelp(editorView, trigger: beforeInputText)
        }
    }

}


// MARK: - Source code edit support

extension EditorViewController {

    private func shouldChange(_ range: NSRange, _ inputText: String) -> Bool {
        switch (inputText, range.length == .zero) {
        case (.tab, true):
            return tab(range)
        case (.tab, false):
            return indent(range)
        case (.lineFeed, true):
            return newLine(range)
        case (.blank, _):
            return delete(range)
        default:
            return true
        }
    }

    private func tab(_ range: NSRange) -> Bool {
        guard indentCharacter == .space else {
            return true
        }

        // Get text up to the cursor
        let lineRange = contentText.lineRange(for: range)
        let beforeCursorRange = NSMakeRange(lineRange.location, range.upperBound - lineRange.lowerBound)
        let beforeCursorText = contentText[beforeCursorRange]

        // Calculate the number of spaces to insert
        let tabCount = beforeCursorText.count(characterSet: .tab)
        let modulus = (beforeCursorText.monospaceCount + (tabCount - tabCount * tabSize)) % tabSize
        let insertment = String(repeating: .space, count: tabSize - modulus)

        editorView.replaceText(in: range, with: insertment, selected: false)
        return false
    }

    private func indent(_ range: NSRange) -> Bool {
        let lineRange = contentText.lineRange(for: range)

        var replacement = ""
        contentText.lines(range: lineRange).forEach() {
            replacement.append(indent)
            replacement.append($0)
        }

        editorView.replaceText(in: lineRange, with: replacement, selected: true)
        return false
    }

    private func newLine(_ range: NSRange) -> Bool {
        guard let syntaxManager = self.syntaxManager else {
            return true
        }

        // Calculate indent level
        let indentLevel = syntaxManager.indent(text: contentText, range: range)
        var insertment = "\n"
        insertment.append(String(repeating: indent, count: indentLevel))

        editorView.replaceText(in: range, with: insertment, selected: false)
        return false
    }

    private func delete(_ range: NSRange) -> Bool {
        guard selectedRange.length == .zero else {
            return true
        }

        let lineRange = contentText.lineRange(for: range)
        let beforeCursor = NSMakeRange(lineRange.location, range.upperBound - lineRange.lowerBound)

        if contentText[beforeCursor].isOnly(characterSet: .indent) {
            editorView.replaceText(in: beforeCursor, with: .blank, selected: false)
            return false
        } else {
            return true
        }
    }

    private func deindent() {
        let lineRange = contentText.lineRange(for: selectedRange)

        var replacement = ""
        contentText.lines(range: lineRange).forEach() {
            if $0.hasPrefix(indent) {
                replacement.append(contentsOf: $0.dropFirst(indent.count))
            } else {
                replacement.append($0)
            }
        }

        editorView.replaceText(in: lineRange, with: replacement, selected: true)
    }

    private func toggleComment() {
        guard let commentOut = syntaxManager?.commentOut else {
            return
        }

        let lineRange = contentText.lineRange(for: selectedRange)

        var onlyComment = true
        var uncomment = ""
        var comment = ""
        contentText.lines(range: lineRange).forEach() {
            if onlyComment && $0.hasPrefix(commentOut) {
                uncomment.append(contentsOf: $0.dropFirst(commentOut.count))
            } else {
                onlyComment = false
                comment.append(commentOut)
                comment.append($0)
            }
        }

        let replacement = onlyComment ? uncomment : comment
        editorView.replaceText(in: lineRange, with: replacement, selected: true)
    }

}


// MARK: - Undo/Redo support

extension EditorViewController {

    private func needRegisterUndo(_ inputText: String) -> Bool {
        switch inputText {
        case "\n":
            return inputText != beforeInputText
        default:
            return false
        }
    }

    private func registerUndo() {
        guard let undoManager = self.undoManager else {
            fatalError()
        }
        // Regist Undo/Redo
        undoManager.registerUndo(withTarget: self, handler: { _ in self.registerUndo() })
    }

}


// MARK: - File change event support

extension EditorViewController {

    func didSendDidChange() {
        isNeedCommitChanges = false
    }

}


// MARK: - Completion support

extension EditorViewController {

    func willSendCompletion(invoke range: NSRange, filter text: String) {
        if let completion = self.completion {
            completion.completionRange = range
            completion.filterText = text

        } else {
            let completion = CompletionViewController()
            completion.completionRange = range
            completion.filterText = text
            add(child: completion)
            self.completion = completion
        }
    }

    func didSendCompletion() {
        isNeedCompletion = false
    }

    func showCompletion(result: CompletionList) {
        guard completion.completionRange == editorView.selectedRange,
              let textPosition = editorView.selectedTextRange?.end else {
            return
        }
        let caretRect = editorView.caretRect(for: textPosition)
        completion.show(with: result, caretRect: caretRect)
    }

    func commitCompletion() {
        completion.hide()

        let completionItem = completion.selectedItem
        let completionRange = completion.completionRange
        let replaceText = completionItem.insertText ?? completionItem.label
        let replaceRange = syntaxManager?.wordRange(text: contentText, range: completionRange) ?? completionRange

        editorView.replaceText(in: replaceRange, with: replaceText, selected: false)
    }

}

// MARK: - Hover support

extension EditorViewController {

    @objc func invokeHover() {
        viewModel.sendDidChange(editorView)
        viewModel.sendHover(editorView)
    }

    func willSendHover(invoke range: NSRange) {
        if let hover = self.hover {
            hover.invokedRange = range

        } else {
            let hover = HoverViewController()
            hover.invokedRange = range
            add(child: hover)
            self.hover = hover
        }
    }

    func showHover(result: Hover) {
        guard hover.invokedRange == editorView.selectedRange,
              let textPosition = editorView.selectedTextRange?.end else {
            return
        }
        let caretRect = editorView.caretRect(for: textPosition)
        hover.show(with: result, caretRect: caretRect)
    }

}


// MARK: - Signature help support

extension EditorViewController {

    func willSendSignatureHelp(invoke range: NSRange) {
        if let signatureHelp = self.signatureHelp {
            signatureHelp.invokedRange = range

        } else {
            let signatureHelp = SignatureHelpViewController()
            signatureHelp.invokedRange = range
            add(child: signatureHelp)
            self.signatureHelp = signatureHelp
        }
    }

    func didSendSignatureHelp() {
        isNeedSignatureHelp = false
    }

    func showSignatureHelp(result: SignatureHelp) {
        guard signatureHelp.invokedRange == editorView.selectedRange,
              let textPosition = editorView.selectedTextRange?.end else {
            return
        }
        let caretRect = editorView.caretRect(for: textPosition)
        signatureHelp.show(with: result, caretRect: caretRect)
    }

}


// MARK: - Find location support

extension EditorViewController {

}


// MARK: - Document highlight support

extension EditorViewController {

}


// MARK: - Document symbol support

extension EditorViewController {

}


// MARK: - Code action support

extension EditorViewController {

}


// MARK: - Formatting support

extension EditorViewController {

}


// MARK: - Rename support

extension EditorViewController {

}


extension TextRange {

    init(_ range: NSRange, in text: String) {
        if text.isEmpty {
            self.start = TextPosition(line: .zero, character: .zero)
            self.end = TextPosition(line: .zero, character: .zero)

        } else {
            let lineRanges = text.lineRanges(range: range)
            guard let start = lineRanges.first, let end = lineRanges.last else {
                fatalError("\(#function) -> in:\(range), \(lineRanges)")
            }
            self.start = TextPosition(line: start.number, character: range.lowerBound - start.range.lowerBound)
            self.end = TextPosition(line: end.number, character: range.upperBound - end.range.lowerBound)
        }
    }

}

extension TextPosition {

    init(_ range: NSRange, in text: String) {
        if text.isEmpty {
            self.line = .zero
            self.character = .zero

        } else {
            guard let line = text.lineRanges(range: range).last else {
                fatalError("\(#function) -> in:\(range), \(text.lineRanges(range: range))")
            }
            self.line = line.number
            self.character = range.upperBound - line.range.lowerBound
        }
    }

}
