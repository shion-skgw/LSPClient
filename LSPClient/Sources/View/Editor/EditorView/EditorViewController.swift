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

    /// CompletionViewController
    private(set) weak var completion: CompletionViewController!
    /// HoverViewController
    private(set) weak var hover: HoverViewController!

    private let serverCapability = ServerCapability.load()

    static let gutterWidth: CGFloat = 40.0
    static let verticalMargin: CGFloat = 4.0

    override var undoManager: UndoManager? {
        self.textView.undoManager
    }

    var isShownCompletion: Bool {
        self.completion?.view.isHidden == false
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
        let syntaxManager = SyntaxManager.load(fileExtension: fileExtension)
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
        guard let text = try? WorkspaceManager.shared.open(uri: uri) else {
            let title = "aaaa"
            let message = ""
            present(UIAlertController.anyAlert(title: title, message: message), animated: true)
            return
        }

        textStorage.replaceCharacters(in: textStorage.string.range, with: text)
        beforeChangesText = text
        sendDidOpen()

        // Notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
        notificationCenter.addObserver(self, selector: #selector(refreshDiagnostics), name: .didReceiveDiagnostics, object: nil)
    }

    @objc private func refreshDiagnostics(_ notification: Notification) {
        guard self.uri == notification.userInfoValue as? DocumentUri,
                let diagnostics = Diagnosis.load()[self.uri] else {
            return
        }
        let dict: [NSRange: DiagnosticSeverity] = diagnostics.reduce(into: [:], {
            $0[NSRange($1.range, in: self.textView.text)] = $1.severity ?? .information
        })
        textStorage.applyDiagnostic(diagnostic: dict)
        textView.setNeedsDisplay()
    }

    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()
        textView.set(codeStyle: codeStyle)
        textStorage.set(codeStyle: codeStyle)
        layoutManager.set(codeStyle: codeStyle)
    }

    private var beforeInputText: String = ""
    private var beforeChangesText: String = ""
    private var isNeedCommitChanges: Bool = false
    private var isNeedCompletion: Bool = false
    private var isNeedSignatureHelp: Bool = false
    private var currentVersion: Int = 1
    private var currentRequestID: RequestID? = nil

    private let otherThanIndentRegex = try! NSRegularExpression(pattern: "[^ \t]+")

    override var keyCommands: [UIKeyCommand]? {
        if isShownCompletion {
            return [
                UIKeyCommand(action: #selector(didInputCommand), input: UIKeyCommand.inputUpArrow),
                UIKeyCommand(action: #selector(didInputCommand), input: UIKeyCommand.inputDownArrow),
            ]
        } else {
            return [
                UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: .shift, action: #selector(didInputCommand)),
                UIKeyCommand(input: UIKeyCommand.inputSlash, modifierFlags: .command, action: #selector(didInputCommand)),
                UIKeyCommand(input: UIKeyCommand.inputSpace, modifierFlags: .alternate, action: #selector(didInputCommand)),
            ]
        }
    }

    @objc private func didInputCommand(_ command: UIKeyCommand) {
        switch (command.input, command.modifierFlags) {
        case (UIKeyCommand.inputTab, .shift):
            deindent()

        case (UIKeyCommand.inputSlash, .command):
            toggleComment()

        case (UIKeyCommand.inputSpace, .alternate):
            sendDidChange()
            initializeCompilation(textView.text, textView.selectedRange)
            sendCompletion(nil)

        case (UIKeyCommand.inputUpArrow, _):
            completion.moveSelect(direction: -)

        case (UIKeyCommand.inputDownArrow, _):
            completion.moveSelect(direction: +)

        default:
            fatalError()
        }
    }

    @objc func invokeHover() {
        sendDidChange()
        initializeHover(textView.selectedRange)
        sendHover()
    }

}


// MARK: - UITextViewDelegate

extension EditorViewController: UITextViewDelegate {

    func textView(_: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if isShownCompletion {
            return shouldChangeCompletion(text, range)
        }

        if needRegisterUndo(text) {
            registerUndo()
        }

        self.isNeedCompletion = needCompletion(text)
        self.isNeedSignatureHelp = needSignatureHelp(text)
        self.isNeedCommitChanges = self.isNeedCompletion || self.isNeedSignatureHelp || needCommitChanges(text)
        self.beforeInputText = text

        return shouldChange(range, text)
    }

    func textViewDidChangeSelection(_: UITextView) {
        if textView.selectedRange.length == .zero {
            print(TextPosition(textView.selectedRange, in: textView.text))
        } else {
            let aaa = TextRange(textView.selectedRange, in: textView.text)
            print(aaa)
        }
        guard let undoManager = self.undoManager else {
            fatalError()
        }

        if isShownCompletion && !completion.completionRange.inRange(textView.selectedRange) {
            completion.hide()
        }

        if isNeedCommitChanges || undoManager.isUndoing || undoManager.isRedoing {
            sendDidChange()
        }

        if isNeedCompletion {
            initializeCompilation(textView.text, textView.selectedRange)
            sendCompletion(beforeInputText)

        } else if isNeedSignatureHelp {
            initializeSignatureHelp(textView.selectedRange)
            sendSignatureHelp(beforeInputText)
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
            return true
        }
    }

    private func tab(_ range: NSRange) -> Bool {
//        let indent = "    "
//        textStorage.replaceCharacters(in: range, with: indent)
        return true
    }

    private func newLine(_ range: NSRange) -> Bool {
        guard let level = syntaxManager?.indent(text: textStorage.string, range: range), level > .zero else {
            return true
        }

        var result = "\n"
        result.append(String(repeating: "    ", count: level))
        textStorage.replaceCharacters(in: range, with: result)
        textView.selectedRange = NSMakeRange(range.location + result.length, 0)

        return false
    }

    private func indent(_ range: NSRange) -> Bool {
        let lineRange = textStorage.string.lineRange(for: range)
        let indent = "    "

        var result = ""
        textStorage.string.lines(range: lineRange).forEach() {
            result.append(indent)
            result.append($0)
        }

        textStorage.replaceCharacters(in: lineRange, with: result)
        textView.selectedRange = NSMakeRange(lineRange.location, result.length)
        return false
    }

    private func delete(_ range: NSRange) -> Bool {
        let lineRange = textStorage.string.lineRange(for: range)

        let beforeCursor = NSMakeRange(lineRange.location, range.location - lineRange.location)
        if otherThanIndentRegex.firstMatch(in: textStorage.string, range: beforeCursor) != nil {
            return true
        }

        textStorage.replaceCharacters(in: beforeCursor, with: "")
        return false
    }

    private func deindent() {
        let lineRange = textStorage.string.lineRange(for: textView.selectedRange)
        let indent = "    "

        var result = ""
        textStorage.string.lines(range: lineRange).forEach() {
            if $0.hasPrefix(indent) {
                result.append(contentsOf: $0.dropFirst(indent.count))
            } else {
                result.append($0)
            }
        }

        textStorage.replaceCharacters(in: lineRange, with: result)
        textView.selectedRange = NSMakeRange(lineRange.location, result.length)
    }

    private func toggleComment() {
        let lineRange = textStorage.string.lineRange(for: textView.selectedRange)
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
                comment.append($0)
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
        return text.contains(characterSet: serverCapability.completion.triggerCharacters)
    }

    private func shouldChangeCompletion(_ text: String, _ range: NSRange) -> Bool {
        if text.contains(characterSet: serverCapability.completion.allCommitCharacters) {
            commitCompletion()
            return false
        } else {
            completion.willInput(text: text, range: range)
            return true
        }
    }

    private func initializeCompilation(_ text: String, _ range: NSRange) {
        guard let syntaxManager = self.syntaxManager else {
            return
        }

        // Get filter text
        var filterText = ""
        if let range = syntaxManager.wordRanges(text: text, range: range).first {
            filterText = (text as NSString).substring(with: range)
        }

        // Compilation initialization
        if let completion = self.completion {
            completion.filterText = filterText
            completion.completionRange = range

        } else {
            let completion = CompletionViewController()
            completion.filterText = filterText
            completion.completionRange = range
            add(child: completion)
            self.completion = completion
        }
    }

    private func sendCompletion(_ trigger: String?) {
        guard serverCapability.completion.isSupport,
                textView.selectedRange.length == .zero else {
            return
        }

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let position = TextPosition(textView.selectedRange, in: textView.text)
        let context = CompletionContext(triggerKind: trigger == nil ? .invoked : .triggerCharacter, triggerCharacter: trigger)
        let completionParams = CompletionParams(textDocument: textDocument, position: position, context: context)

        // Send request "textDocument/completion"
        currentRequestID = completion(params: completionParams)

        // Update status
        isNeedCompletion = false
    }

    private func commitCompletion() {
        guard let syntaxManager = self.syntaxManager else {
            return
        }

        completion.hide()

        let completionItem = completion.selectedItem
        let completionRange = completion.completionRange
        let replaceText = completionItem.insertText ?? ""
        let replaceRange = syntaxManager.wordRanges(text: textStorage.string, range: completionRange).first ?? completionRange

        textStorage.replaceCharacters(in: replaceRange, with: replaceText)
        textView.selectedRange = NSMakeRange(replaceRange.location + replaceText.length, .zero)
    }

}


// MARK: - Hover support

extension EditorViewController {

    private func initializeHover(_ range: NSRange) {
        // Hover initialization
        if let hover = self.hover {

        } else {
            let hover = HoverViewController()
            add(child: hover)
            self.hover = hover
        }
    }

    private func sendHover() {
        guard serverCapability.hover.isSupport else {
            return
        }

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let position = TextPosition(textView.selectedRange, in: textView.text)
        let hoverParams = HoverParams(textDocument: textDocument, position: position)

        // Send request
        currentRequestID = hover(params: hoverParams)
    }

}


// MARK: - Signature help support

extension EditorViewController {

    private func needSignatureHelp(_ text: String) -> Bool {
        return text.contains(characterSet: serverCapability.signatureHelp.triggerCharacters)
    }

    private func initializeSignatureHelp(_ range: NSRange) {
    }

    private func sendSignatureHelp(_ trigger: String) {
        guard serverCapability.signatureHelp.isSupport,
                textView.selectedRange.length == .zero else {
            return
        }

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let position = TextPosition(textView.selectedRange, in: textView.text)
        let context = SignatureHelpContext(triggerKind: .triggerCharacter, triggerCharacter: trigger, isRetrigger: false, activeSignatureHelp: nil)
        let signatureHelpParams = SignatureHelpParams(textDocument: textDocument, position: position, context: context)

        // Send request
        currentRequestID = signatureHelp(params: signatureHelpParams)
    }

}


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

    private func needCommitChanges(_ text: String) -> Bool {
        return beforeInputText != text && syntaxManager?.word(text: text) ?? false
    }

    private func sendDidOpen() {
        guard serverCapability.textDocumentSync.openClose else {
            return
        }

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

        // Send notification
        switch serverCapability.textDocumentSync.change {
        case .none:
            break
        case .full:
            sendDidChangeFull()
        case .incremental:
            sendDidChangeIncremental()
        }

        // Update status
        isNeedCommitChanges = false
        beforeChangesText = textStorage.string
    }

    private func sendDidChangeFull() {
        // Generate parameters
        currentVersion += 1
        let textDocument = VersionedTextDocumentIdentifier(uri: uri, version: currentVersion)
        let contentChange = TextDocumentContentChangeEvent.full(textStorage.string)
        let didChangeParams = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [contentChange])

        // Send notification "textDocument/didChange"
        didChange(params: didChangeParams)
    }

    private func sendDidChangeIncremental() {
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
    }

    private func sendDidSave() {
        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let didOpenParams = DidSaveTextDocumentParams(textDocument: textDocument, text: textStorage.string)

        // Send notification "textDocument/didSave"
        didSave(params: didOpenParams)
    }

    private func sendDidClose() {
        guard serverCapability.textDocumentSync.openClose else {
            return
        }

        // Send notification "textDocument/didClose"
        let textDocument = TextDocumentIdentifier(uri: uri)
        let didCloseParams = DidCloseTextDocumentParams(textDocument: textDocument)
        didClose(params: didCloseParams)
    }

}


// MARK: - Language server support

extension EditorViewController: TextDocumentMessageDelegate {

    func completion(id: RequestID, result: CompletionList?) {
        guard currentRequestID == id,
                completion.completionRange == textView.selectedRange,
                let completionList = result, !completionList.items.isEmpty,
                let selectedTextRange = textView.selectedTextRange?.end else {
            return
        }

        let caretRect = textView.caretRect(for: selectedTextRange)
        completion.show(items: completionList.items, caretRect: caretRect)

        if !completionList.isIncomplete {
            currentRequestID = nil
        }
    }

    func completionResolve(id: RequestID, result: CompletionItem) {
    }
    func hover(id: RequestID, result: Hover?) {
    }
    func signatureHelp(id: RequestID, result: SignatureHelp?) {
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
        print(#function, id, method, error)
    }

}

extension TextRange {

    init(_ range: NSRange, in text: String) {
        if text.isEmpty {
            self.start = TextPosition(line: .zero, character: .zero)
            self.end = TextPosition(line: .zero, character: .zero)

        } else {
            let lineRanges = text.lineRanges(range: range)
            guard let start = lineRanges.first,
                    let end = lineRanges.last,
                    let startDistance = Range(NSMakeRange(start.range.lowerBound, range.lowerBound - start.range.lowerBound), in: text),
                    let endDistance = Range(NSMakeRange(end.range.lowerBound, range.upperBound - end.range.lowerBound), in: text) else {
                fatalError()
            }
            let startCharacter = text.utf8.distance(from: startDistance.lowerBound, to: startDistance.upperBound)
            let endCharacter = text.utf8.distance(from: endDistance.lowerBound, to: endDistance.upperBound)
            self.start = TextPosition(line: start.number, character: startCharacter)
            self.end = TextPosition(line: end.number, character: endCharacter)
        }
    }

}

extension TextPosition {

    init(_ range: NSRange, in text: String) {
        if text.isEmpty {
            self.line = .zero
            self.character = .zero

        } else {
            guard let line = text.lineRanges(range: range).last,
                    let distance = Range(NSMakeRange(line.range.lowerBound, range.lowerBound - line.range.lowerBound), in: text) else {
                fatalError()
            }
            self.line = line.number
            self.character = text.utf8.distance(from: distance.lowerBound, to: distance.upperBound)
        }
    }

}
