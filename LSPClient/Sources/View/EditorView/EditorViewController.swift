//
//  EditorViewController.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController{

    /// EditorView
    private(set) weak var textView: EditorView!
    /// EditorTextStorage
    private(set) weak var textStorage: EditorTextStorage!
    /// EditorLayoutManager
    private(set) weak var layoutManager: EditorLayoutManager!
    /// SyntaxManager
    private(set) weak var syntaxManager: SyntaxManager?

    override var undoManager: UndoManager? {
        self.textView.undoManager
    }

    var uri: DocumentUri!
    var fileExtension: String {
        uri?.pathExtension ?? ""
    }

    override func loadView() {
        let codeStyle = CodeStyle.load()
        let editorSetting = EditorSetting.load()

        // TextContainer
        let textContainer = NSTextContainer()

        // LayoutManager
        let layoutManager = EditorLayoutManager()
        layoutManager.set(editorSetting: editorSetting)
        layoutManager.set(codeStyle: codeStyle)
        layoutManager.addTextContainer(textContainer)
        self.layoutManager = layoutManager

        // SyntaxManager
        let syntaxManager = SyntaxManager.load(fileExtension: "swift")
        self.syntaxManager = syntaxManager

        // TextStorage
        let textStorage = EditorTextStorage(syntaxManager: syntaxManager)
        textStorage.set(codeStyle: codeStyle)
        textStorage.addLayoutManager(layoutManager)
        self.textStorage = textStorage

        // EditorView
        let textView = EditorView(frame: .zero, textContainer: textContainer)
        textView.set(editorSetting: editorSetting)
        textView.set(codeStyle: codeStyle)
        textView.delegate = self
        self.textView = textView
        self.view = textView
    }

    override func viewDidLoad() {
        do {
            let text = try WorkspaceManager.shared.open(uri: uri)
            textView.text = text
            beforeCommitText = text

        } catch WorkspaceError.fileNotFound {
            present(UIAlertController.fileNotFound(uri: uri), animated: true)

        } catch WorkspaceError.encodingFailure {
            try? WorkspaceManager.shared.remove(uri: uri)
            present(UIAlertController.unsupportedFile(uri: uri), animated: true)

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
    private var beforeCommitText: String = ""
    private var isNeedCommit: Bool = false
    private var isNeedCompletion: Bool = false

    private let otherThanIndentRegex = try! NSRegularExpression(pattern: "[^ \t]+")

    override var keyCommands: [UIKeyCommand]? {
        [
            // Deindent
            UIKeyCommand(input: "\t", modifierFlags: [.shift], action: #selector(deindent)),
            // Comment out
            UIKeyCommand(input: "/", modifierFlags: [.command], action: #selector(toggleComment)),
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
        self.isNeedCommit = !isShouldChange || isNeedRegisterUndo || self.isNeedCompletion
        self.beforeInputText = text

        return isShouldChange
    }

    func textViewDidChangeSelection(_: UITextView) {
        guard let undoManager = self.undoManager else {
            fatalError()
        }

        if isNeedCommit || undoManager.isUndoing || undoManager.isRedoing {
            commit()
        }

        if isNeedCompletion {
            completion()
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
        let indent = "    "
        textStorage.replaceCharacters(in: range, with: indent)
        return true
    }

    private func newLine(_ range: NSRange) -> Bool {
        guard let level = syntaxManager?.indentLevel(text: textStorage.string, location: range.location), level >= .zero else {
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
        textStorage.string.enumerateLines(range: lineRange) {
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
        textStorage.string.enumerateLines(range: lineRange) {
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
        textStorage.string.enumerateLines(range: lineRange) {
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


// MARK: - Committing edits support

extension EditorViewController {

    private func commit() {
        guard textStorage.string != beforeCommitText else {
            return
        }

        let changes = textStorage.string.changes(from: beforeCommitText)
        let range = changes.range
        let replace = changes.text.replacingOccurrences(of: "\n", with: "\\n")
        print("commit -> range: \(range), replace: \"\(replace)\"")

        beforeCommitText = textStorage.string
        isNeedCommit = false
    }

}


// MARK: - Completion support

extension EditorViewController {

    private func needCompletion(_ text: String) -> Bool {
        return ".;".contains(text)
    }

    private func completion() {
        guard textView.selectedRange.length != .zero else {
            return
        }

        let range = textView.selectedRange
        print("range: \(range)")
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
        let languageId = LanguageID.of(fileExtension: fileExtension)
        let text = textStorage.string
        let textDocument = TextDocumentItem(uri: uri, languageId: languageId, version: 1, text: text)

        let didOpenParams = DidOpenTextDocumentParams(textDocument: textDocument)

        didOpen(params: didOpenParams)
    }

    private func sendDidChange() {

    }

    private func sendDidSave() {

    }

}


// MARK: - Language server support

extension EditorViewController: TextDocumentMessageDelegate {

    func completion(id: RequestID, result: Result<CompletionList?, ErrorResponse>) {}
    func completionResolve(id: RequestID, result: Result<CompletionItem, ErrorResponse>) {}
    func hover(id: RequestID, result: Result<Hover?, ErrorResponse>) {}
//    func declaration(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>) {}
    func definition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>) {}
    func typeDefinition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>) {}
    func implementation(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>) {}
    func references(id: RequestID, result: Result<[Location]?, ErrorResponse>) {}
    func documentHighlight(id: RequestID, result: Result<[DocumentHighlight]?, ErrorResponse>) {}
    func documentSymbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>) {}
    func codeAction(id: RequestID, result: Result<CodeActionResult?, ErrorResponse>) {}
//    func formatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>) {}
    func rangeFormatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>) {}
    func rename(id: RequestID, result: Result<WorkspaceEdit?, ErrorResponse>) {}

}
