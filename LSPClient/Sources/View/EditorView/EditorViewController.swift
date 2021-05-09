//
//  EditorViewController.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController {

    /// EditorView
    private(set) weak var textView: EditorView!
    /// EditorTextStorage
    private(set) weak var textStorage: EditorTextStorage!
    /// EditorLayoutManager
    private(set) weak var layoutManager: EditorLayoutManager!
    /// SyntaxManager
    private(set) weak var syntaxManager: SyntaxManager?

    private(set) weak var completion: CompletionViewController?

    static let gutterWidth: CGFloat = 40.0
    static let verticalMargin: CGFloat = 4.0

    override var undoManager: UndoManager? {
        self.textView.undoManager
    }

    var uri: DocumentUri!
    var fileExtension: String {
        uri?.pathExtension ?? ""
    }

    override func loadView() {
        let codeStyle = CodeStyle.load()

        // TextContainer
        let textContainer = NSTextContainer()

        // LayoutManager
        let layoutManager = EditorLayoutManager()
        layoutManager.addTextContainer(textContainer)
        layoutManager.set(codeStyle: codeStyle)
        self.layoutManager = layoutManager

        // SyntaxManager
        let syntaxManager = SyntaxManager.load(fileExtension: "swift")
        self.syntaxManager = syntaxManager

        // TextStorage
        let textStorage = EditorTextStorage()
        textStorage.syntaxManager = syntaxManager
        textStorage.addLayoutManager(layoutManager)
        textStorage.set(codeStyle: codeStyle)
        self.textStorage = textStorage

        // EditorView
        let textView = EditorView(frame: .zero, textContainer: textContainer)
        textView.set(codeStyle: codeStyle)
        textView.delegate = self
        self.textView = textView
        self.view = textView
    }

    override func viewDidLoad() {
        do {
            let text = try WorkspaceManager.shared.open(uri: uri)
            textStorage.replaceCharacters(in: textStorage.string.range, with: text)
            beforeChangesText = text
            sendDidOpen()

        } catch {
            let title = "aaaa"
            let message = error.localizedDescription
            present(UIAlertController.anyAlert(title: title, message: message), animated: true)
        }
    }

    func set(codeStyle: CodeStyle) {
        textView.set(codeStyle: codeStyle)
        textStorage.set(codeStyle: codeStyle)
        layoutManager.set(codeStyle: codeStyle)
    }

    private var beforeInputText: String = ""
    private var beforeChangesText: String = ""
    private var isNeedCommitChanges: Bool = false
    private var isNeedCompletion: Bool = false
    private var currentVersion: Int = 1
    private var currentRequestID: RequestID? = nil

    private let otherThanIndentRegex = try! NSRegularExpression(pattern: "[^ \t]+")

    override var keyCommands: [UIKeyCommand]? {
        [
            // Deindent
            UIKeyCommand(input: "\t", modifierFlags: [.shift], action: #selector(deindent)),
            // Comment out
            UIKeyCommand(input: "/", modifierFlags: [.command], action: #selector(toggleComment)),
            UIKeyCommand(input: " ", modifierFlags: .alternate, action: #selector(sendCompletion))
        ]
    }

}


// MARK: - UITextViewDelegate

extension EditorViewController: UITextViewDelegate {

    func textView(_: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let isShouldChange = shouldChange(range, text)
        let isNeedRegisterUndo = needRegisterUndo(text)

        if isNeedRegisterUndo {
            registerUndo()
        }

        self.isNeedCompletion = needCompletion(text)
        self.isNeedCommitChanges = !isShouldChange || isNeedRegisterUndo || self.isNeedCompletion
        self.beforeInputText = text

        return isShouldChange
    }

    func textViewDidChangeSelection(_: UITextView) {
        guard let undoManager = self.undoManager else {
            fatalError()
        }

        if isNeedCommitChanges || undoManager.isUndoing || undoManager.isRedoing {
            sendDidChange()
        }

        if isNeedCompletion {
            sendCompletion()
        }
    }

}


// MARK: - Source code edit support

extension EditorViewController {

    private func shouldChange(_ range: NSRange, _ text: String) -> Bool {
        switch (text, range.length == .zero) {
        case ("\t", true):
            return tab(range)
        case ("\t", false):
            return indent(range)
        case ("\n", true):
            return newLine(range)
        case ("", true):
            return delete(range)
        default:
            if "({".contains(text) {
                return enclosing(range, text)
            } else {
                return true
            }
        }
    }

    private func tab(_ range: NSRange) -> Bool {
//        let indent = "    "
//        textStorage.replaceCharacters(in: range, with: indent)
        return true
    }

    private func newLine(_ range: NSRange) -> Bool {
        guard let level = syntaxManager?.indentLevel(text: textStorage.string, location: range.location), level > .zero else {
            return true
        }

        var result = "\n"
        result.append(String(repeating: "    ", count: level))
        textStorage.replaceCharacters(in: range, with: result)
        textView.selectedRange = NSMakeRange(range.location + result.length, 0)

        return false
    }

    private func enclosing(_ range: NSRange, _ text: String) -> Bool {
        return true
    }

    private func indent(_ range: NSRange) -> Bool {
        let lineRange = (textStorage.string as NSString).lineRange(for: range)
        let indent = "    "

        var result = ""
        textStorage.string.lines(range: lineRange).forEach() {
            result.append(indent)
            result.append(contentsOf: $0)
        }

        textStorage.replaceCharacters(in: lineRange, with: result)
        textView.selectedRange = NSMakeRange(lineRange.location, result.length)
        return false
    }

    private func delete(_ range: NSRange) -> Bool {
        let lineRange = (textStorage.string as NSString).lineRange(for: range)

        let beforeCursor = NSMakeRange(lineRange.location, range.location - lineRange.location)
        if otherThanIndentRegex.firstMatch(in: textStorage.string, range: beforeCursor) != nil {
            return true
        }

        textStorage.replaceCharacters(in: beforeCursor, with: "")
        return false
    }

    @objc private func deindent() {
        let fullText = textStorage.string as NSString
        let lineRange = fullText.lineRange(for: textView.selectedRange)
        let indent = "    "

        var result = ""
        textStorage.string.lines(range: lineRange).forEach() {
            if $0.hasPrefix(indent) {
                result.append(contentsOf: $0.dropFirst(indent.count))
            } else {
                result.append(contentsOf: $0)
            }
        }

        textStorage.replaceCharacters(in: lineRange, with: result)
        textView.selectedRange = NSMakeRange(lineRange.location, result.length)
    }

    @objc private func toggleComment() {
        let fullText = textStorage.string as NSString
        let lineRange = fullText.lineRange(for: textView.selectedRange)
        let singleLineComment = "//"

        var onlyComment = true
        var uncomment = ""
        var comment = ""
        textStorage.string.lines(range: lineRange).forEach() {
            if onlyComment && $0.hasPrefix(singleLineComment) {
                uncomment.append(contentsOf: $0.dropFirst(singleLineComment.count))
            } else {
                onlyComment = false
                comment.append(singleLineComment)
                comment.append(contentsOf: $0)
            }
        }

        let result = onlyComment ? uncomment : comment
        textStorage.replaceCharacters(in: lineRange, with: result)
        textView.selectedRange = NSMakeRange(lineRange.location, result.length)
    }

}


// MARK: - Undo/Redo support

extension EditorViewController {

    private func needRegisterUndo(_ text: String) -> Bool {
        switch text {
        case "\n":
            return text != beforeInputText
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


// MARK: - Completion support

extension EditorViewController {

    private func needCompletion(_ text: String) -> Bool {
        return "." == text
    }

    @objc private func sendCompletion() {
        guard let range = Range(textView.selectedRange, in: textView.text), range.isEmpty else {
            return
        }

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let position = TextPosition(range, in: textView.text)
        let context = CompletionContext(triggerKind: .invoked, triggerCharacter: "a")
        let completionParams = CompletionParams(textDocument: textDocument, position: position, context: context)

        // Send request "textDocument/completion"
        currentRequestID = completion(params: completionParams)

        // Update status
        isNeedCompletion = false
    }

}


// MARK: - Hover support

extension EditorViewController {}


// MARK: - Definition support

extension EditorViewController {}


// MARK: - Document highlight support

extension EditorViewController {}


// MARK: - Document symbol support

extension EditorViewController {}


// MARK: - Code action support

extension EditorViewController {}


// MARK: - Code formatting support

extension EditorViewController {}


// MARK: - Symbol rename support

extension EditorViewController {}


// MARK: - File change event support

extension EditorViewController {

    private func sendDidOpen() {
        // Generate parameters
        let languageId = LanguageID.of(fileExtension: fileExtension)
        let textDocument = TextDocumentItem(uri: uri, languageId: languageId, version: currentVersion, text: textStorage.string)
        let didOpenParams = DidOpenTextDocumentParams(textDocument: textDocument)

        // Send notification "textDocument/didOpen"
        didOpen(params: didOpenParams)
    }

    private func sendDidChange() {
        guard textStorage.string != beforeChangesText else {
            return
        }

        // Get the changes
        let changes = textStorage.string.changes(from: beforeChangesText)

        // Generate parameters
        currentVersion += 1
        let textDocument = VersionedTextDocumentIdentifier(uri: uri, version: currentVersion)
        let range = TextRange(changes.range, in: beforeChangesText)
        let contentChange = TextDocumentContentChangeEvent.incremental(range, changes.text)
        let didChangeParams = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [contentChange])

        // Send notification "textDocument/didChange"
        didChange(params: didChangeParams)

        // Update status
        isNeedCommitChanges = false
        beforeChangesText = textStorage.string
    }

    private func sendDidSave() {
        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let didOpenParams = DidSaveTextDocumentParams(textDocument: textDocument, text: textStorage.string)

        // Send notification "textDocument/didSave"
        didSave(params: didOpenParams)
    }

}


// MARK: - Language server support

extension EditorViewController: TextDocumentMessageDelegate {

    func completion(id: RequestID, result: CompletionList?) {
        guard result?.items.isEmpty == false else {
            return
        }
        let a = CompletionViewController()
        a.data = result
        add(child: a)
    }
    func completionResolve(id: RequestID, result: CompletionItem) {
    }
    func hover(id: RequestID, result: Hover?) {
    }
//    func declaration(id: RequestID, result: FindLocationResult?) {}
    func definition(id: RequestID, result: FindLocationResult?) {
    }
    func typeDefinition(id: RequestID, result: FindLocationResult?) {
    }
    func implementation(id: RequestID, result: FindLocationResult?) {
    }
    func references(id: RequestID, result: [Location]?) {
    }
    func documentHighlight(id: RequestID, result: [DocumentHighlight]?) {
    }
    func documentSymbol(id: RequestID, result: [SymbolInformation]?) {
    }
    func codeAction(id: RequestID, result: CodeActionResult?) {
    }
//    func formatting(id: RequestID, result: [TextEdit]?) {}
    func rangeFormatting(id: RequestID, result: [TextEdit]?) {
    }
    func rename(id: RequestID, result: WorkspaceEdit?) {
    }
    func responseError(id: RequestID, method: MessageMethod, error: ErrorResponse) {
    }

}

extension TextRange {

    init(_ range: Range<String.Index>, in text: String) {
        let lineRanges = text.lineRanges(range: NSRange(text.lineRange(for: range), in: text))
        if let start = lineRanges.first, let end = lineRanges.last {
            let startCharacter = text.utf8.distance(from: start.range.lowerBound, to: range.lowerBound)
            self.start = TextPosition(line: start.line, character: startCharacter)
            let endCharacter = text.utf8.distance(from: end.range.lowerBound, to: range.upperBound)
            self.end = TextPosition(line: end.line, character: endCharacter)

        } else {
            self.start = TextPosition(line: .zero, character: .zero)
            self.end = TextPosition(line: .zero, character: .zero)
            if !text.isEmpty { fatalError() }
        }
    }

}

extension TextPosition {

    init(_ range: Range<String.Index>, in text: String) {
        let lineRanges = text.lineRanges(range: NSRange(range, in: text))
        if let start = lineRanges.first {
            self.line = start.line
            self.character = text.utf8.distance(from: start.range.lowerBound, to: range.upperBound)

        } else {
            self.line = .zero
            self.character = .zero
            if !text.isEmpty { fatalError() }
        }
    }

}
