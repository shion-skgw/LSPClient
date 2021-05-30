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
        self.textView.text
    }
    private var selectedRange: NSRange {
        get {
            self.textView.selectedRange
        }
        set {
            self.textView.selectedRange = newValue
        }
    }


    private let serverCapability = ServerCapability.load()

    static let gutterWidth: CGFloat = 40.0
    static let verticalMargin: CGFloat = 4.0

    override var undoManager: UndoManager? {
        self.textView.undoManager
    }

    var uri: DocumentUri = .bluff

    override func loadView() {
        // TextContainer
        let textContainer = NSTextContainer()
        textContainer.lineBreakMode = .byCharWrapping

        // LayoutManager
        let layoutManager = EditorLayoutManager()
        layoutManager.addTextContainer(textContainer)
        self.layoutManager = layoutManager

        // SyntaxManager
        let syntaxManager = SyntaxManager.load(fileExtension: uri.pathExtension)
        self.syntaxManager = syntaxManager

        // TextStorage
        let textStorage = EditorTextStorage()
        textStorage.syntaxManager = syntaxManager
        textStorage.addLayoutManager(layoutManager)
        self.textStorage = textStorage

        // EditorView
        let textView = EditorView(frame: .zero, textContainer: textContainer)
        textView.delegate = self
        self.textView = textView
        self.view = textView

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
        beforeChangesText = text
        sendDidOpen()

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
        textView.setNeedsDisplay()
    }

    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()
        self.tabSize = codeStyle.tabSize
        self.indentCharacter = codeStyle.useHardTab ? .tab : .space
        self.textView.set(codeStyle: codeStyle)
        self.textStorage.set(codeStyle: codeStyle)
        self.layoutManager.set(codeStyle: codeStyle)
    }

    private var tabSize: Int = 0
    private var indentCharacter: String = ""
    private var indent: String {
        self.indentCharacter == .tab ? .tab : String(repeating: self.indentCharacter, count: self.tabSize)
    }

    private var beforeInputText: String = ""
    private var beforeChangesText: String = ""
    private var isNeedCommitChanges: Bool = false
    private var isNeedCompletion: Bool = false
    private var isNeedSignatureHelp: Bool = false
    private var currentVersion: Int = 1
    var currentRequestID: RequestID? = nil

    override var keyCommands: [UIKeyCommand]? {
        var commands: [UIKeyCommand] = [
            // Deindent
            UIKeyCommand(input: UIKeyCommand.inputTab, modifierFlags: .shift, action: #selector(didInputCommand)),
        ]
        if syntaxManager != nil {
            commands.append(contentsOf: [
                // Compilation
                UIKeyCommand(input: UIKeyCommand.inputSlash, modifierFlags: .command, action: #selector(didInputCommand)),
                // Move caret to previous
                UIKeyCommand(input: UIKeyCommand.inputRightArrow, modifierFlags: .alternate, action: #selector(didInputCommand)),
                // Move caret to next
                UIKeyCommand(input: UIKeyCommand.inputLeftArrow, modifierFlags: .alternate, action: #selector(didInputCommand)),
            ])
        }
        if isShownCompletion {
            commands.append(contentsOf: [
                // Move completion item to previous
                UIKeyCommand(input: UIKeyCommand.inputUpArrow, modifierFlags: [], action: #selector(didInputCommand)),
                // Move completion item to next
                UIKeyCommand(input: UIKeyCommand.inputDownArrow, modifierFlags: [], action: #selector(didInputCommand)),
            ])
        } else if serverCapability.completion.isSupport {
            commands.append(contentsOf: [
                // Invoke completion
                UIKeyCommand(input: UIKeyCommand.inputSpace, modifierFlags: .alternate, action: #selector(didInputCommand)),
            ])
        }
        return commands
    }

    @objc private func didInputCommand(_ command: UIKeyCommand) {
        switch (command.input, command.modifierFlags) {
        case (UIKeyCommand.inputTab, .shift):
            deindent()

        case (UIKeyCommand.inputSlash, .command):
            toggleComment()

        case (UIKeyCommand.inputSpace, .alternate):
            sendDidChange()
            initializeCompilation()
            sendCompletion(nil)

        case (UIKeyCommand.inputLeftArrow, _):
            moveCaretPrevious()

        case (UIKeyCommand.inputRightArrow, _):
            moveCaretNext()

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
        initializeHover(selectedRange)
        sendHover()
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
            return shouldChangeCompletion(range, inputText)

        } else {
            if needRegisterUndo(inputText) {
                registerUndo()
            }
            isNeedCompletion = needCompletion(inputText)
            isNeedSignatureHelp = needSignatureHelp(inputText)
            isNeedCommitChanges = isNeedCompletion || isNeedSignatureHelp || needCommitChanges(inputText)
            beforeInputText = inputText
            return shouldChange(range, inputText)
        }
    }

    func textViewDidChangeSelection(_: UITextView) {
        if selectedRange.length == .zero {
            print(TextPosition(selectedRange, in: contentText))
        } else {
            print(TextRange(selectedRange, in: contentText))
        }
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
            sendDidChange()
        }
        if isNeedCompletion {
            initializeCompilation()
            sendCompletion(beforeInputText)
        }
        if isNeedSignatureHelp {
            initializeSignatureHelp()
            sendSignatureHelp(beforeInputText)
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

        textStorage.replaceCharacters(in: range, with: insertment)
        selectedRange = NSMakeRange(range.location + insertment.length, 0)
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

        textStorage.replaceCharacters(in: range, with: insertment)
        selectedRange = NSMakeRange(range.location + insertment.length, 0)
        return false
    }

    private func indent(_ range: NSRange) -> Bool {
        let lineRange = contentText.lineRange(for: range)

        var replacement = ""
        contentText.lines(range: lineRange).forEach() {
            replacement.append(indent)
            replacement.append($0)
        }

        textStorage.replaceCharacters(in: lineRange, with: replacement)
        selectedRange = NSMakeRange(lineRange.location, replacement.length)
        return false
    }

    private func delete(_ range: NSRange) -> Bool {
        guard selectedRange.length == .zero else {
            return true
        }

        let lineRange = contentText.lineRange(for: range)
        let beforeCursor = NSMakeRange(lineRange.location, range.upperBound - lineRange.lowerBound)

        if contentText[beforeCursor].isOnly(characterSet: .indent) {
            textStorage.replaceCharacters(in: beforeCursor, with: "")
            selectedRange = NSMakeRange(lineRange.location, .zero)
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

        textStorage.replaceCharacters(in: lineRange, with: replacement)
        selectedRange = NSMakeRange(lineRange.location, replacement.length)
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
        textStorage.replaceCharacters(in: lineRange, with: replacement)
        selectedRange = NSMakeRange(lineRange.location, replacement.length)
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


// MARK: - Completion support

extension EditorViewController {

    private func needCompletion(_ inputText: String) -> Bool {
        return inputText.contains(characterSet: serverCapability.completion.triggerCharacters)
    }

    private func shouldChangeCompletion(_ range: NSRange, _ inputText: String) -> Bool {
        if inputText.contains(characterSet: serverCapability.completion.allCommitCharacters) {
            commitCompletion()
            return false
        } else {
            completion.willInput(text: inputText, range: range)
            return true
        }
    }

    private func initializeCompilation() {
        guard let syntaxManager = self.syntaxManager else {
            return
        }

        // Get filter text
        var filterText = ""
        if let range = syntaxManager.wordRange(text: contentText, range: selectedRange) {
            filterText = contentText[range]
        }

        // Compilation initialization
        if let completion = self.completion {
            completion.filterText = filterText
            completion.completionRange = selectedRange

        } else {
            let completion = CompletionViewController()
            completion.filterText = filterText
            completion.completionRange = selectedRange
            add(child: completion)
            self.completion = completion
        }
    }

    private func sendCompletion(_ trigger: String?) {
        guard serverCapability.completion.isSupport,
                selectedRange.length == .zero else {
            return
        }

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let position = TextPosition(selectedRange, in: contentText)
        let context = CompletionContext(triggerKind: trigger == nil ? .invoked : .triggerCharacter, triggerCharacter: trigger)
        let completionParams = CompletionParams(textDocument: textDocument, position: position, context: context)

        // Send request "textDocument/completion"
        currentRequestID = completion(params: completionParams)

        // Update status
        isNeedCompletion = false
    }

    func commitCompletion() {
        guard let syntaxManager = self.syntaxManager else {
            return
        }

        completion.hide()

        let completionItem = completion.selectedItem
        let completionRange = completion.completionRange
        let replaceText = completionItem.insertText ?? ""
        let replaceRange = syntaxManager.wordRange(text: contentText, range: selectedRange) ?? completionRange

        textStorage.replaceCharacters(in: replaceRange, with: replaceText)
        selectedRange = NSMakeRange(replaceRange.location + replaceText.length, .zero)
    }

}


// MARK: - Hover support

extension EditorViewController {

    private func initializeHover(_ range: NSRange) {
        // Hover initialization
        if let hover = self.hover {
            hover.invokedRange = selectedRange

        } else {
            let hover = HoverViewController()
            hover.invokedRange = selectedRange
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
        let position = TextPosition(selectedRange, in: contentText)
        let hoverParams = HoverParams(textDocument: textDocument, position: position)

        // Send request
        currentRequestID = hover(params: hoverParams)
    }

}


// MARK: - Signature help support

extension EditorViewController {

    private func needSignatureHelp(_ inputText: String) -> Bool {
        return inputText.contains(characterSet: serverCapability.signatureHelp.triggerCharacters)
    }

    private func initializeSignatureHelp() {
        // Hover initialization
        if let signatureHelp = self.signatureHelp {
            signatureHelp.invokedRange = selectedRange

        } else {
            let signatureHelp = SignatureHelpViewController()
            signatureHelp.invokedRange = selectedRange
            add(child: signatureHelp)
            self.signatureHelp = signatureHelp
        }
    }

    private func sendSignatureHelp(_ trigger: String) {
        guard serverCapability.signatureHelp.isSupport,
                selectedRange.length == .zero else {
            return
        }

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: uri)
        let position = TextPosition(selectedRange, in: contentText)
        let context = SignatureHelpContext(triggerKind: .triggerCharacter, triggerCharacter: trigger, isRetrigger: false, activeSignatureHelp: nil)
        let signatureHelpParams = SignatureHelpParams(textDocument: textDocument, position: position, context: context)

        // Send request
        currentRequestID = signatureHelp(params: signatureHelpParams)

        // Update status
        isNeedSignatureHelp = false
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

    private func needCommitChanges(_ inputText: String) -> Bool {
        guard let syntaxManager = self.syntaxManager else {
            return false
        }
        return beforeInputText != inputText && !syntaxManager.word(text: inputText)
    }

    private func sendDidOpen() {
        guard serverCapability.textDocumentSync.openClose else {
            return
        }

        // Generate parameters
        let languageId = LanguageID.of(fileExtension: uri.pathExtension)
        let textDocument = TextDocumentItem(uri: uri, languageId: languageId, version: currentVersion, text: contentText)
        let didOpenParams = DidOpenTextDocumentParams(textDocument: textDocument)

        // Send notification "textDocument/didOpen"
        didOpen(params: didOpenParams)
    }

    private func sendDidChange() {
        guard contentText != beforeChangesText else {
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
        beforeChangesText = contentText
    }

    private func sendDidChangeFull() {
        // Generate parameters
        currentVersion += 1
        let textDocument = VersionedTextDocumentIdentifier(uri: uri, version: currentVersion)
        let contentChange = TextDocumentContentChangeEvent.full(contentText)
        let didChangeParams = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [contentChange])

        // Send notification "textDocument/didChange"
        didChange(params: didChangeParams)
    }

    private func sendDidChangeIncremental() {
        // Get the changes
        let changes = contentText.changes(from: beforeChangesText)

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
        let didOpenParams = DidSaveTextDocumentParams(textDocument: textDocument, text: contentText)

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
        guard completion.completionRange == selectedRange,
                let selectedTextRange = textView.selectedTextRange?.end,
                let result = result, result.items.isNotEmpty else {
            return
        }

        let caretRect = textView.caretRect(for: selectedTextRange)
        completion.show(list: result, caretRect: caretRect)

        if !result.isIncomplete {
            currentRequestID = nil
        }
    }

    func completionResolve(id: RequestID, result: CompletionItem) {
    }

    func hover(id: RequestID, result: Hover?) {
        guard hover.invokedRange == selectedRange,
                let selectedTextRange = textView.selectedTextRange?.end,
                let result = result, result.contents.value.isNotEmpty else {
            return
        }

        let caretRect = textView.caretRect(for: selectedTextRange)
        hover.show(hover: result, caretRect: caretRect)
    }

    func signatureHelp(id: RequestID, result: SignatureHelp?) {
        guard signatureHelp.invokedRange == selectedRange,
                let selectedTextRange = textView.selectedTextRange?.end,
                let result = result, result.signatures.isNotEmpty else {
            return
        }

        let caretRect = textView.caretRect(for: selectedTextRange)
        signatureHelp.show(signatures: result, caretRect: caretRect)
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
