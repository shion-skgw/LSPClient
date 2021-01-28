//
//  EditorViewController.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController {

    var uri: DocumentUri!
    var fileExtension: String {
        uri?.pathExtension ?? "swift"
    }
    private var requestId: RequestID?
    private var editorUndoManager: EditorUndoManager!
    private weak var editorView: EditorView!
    private weak var editorTextStorage: EditorTextStorage!
    private weak var editorLayoutManager: EditorLayoutManager!

    override var undoManager: UndoManager? {
        editorUndoManager
    }

    override func loadView() {
        let codeStyle = CodeStyle.load()
        let editorSetting = EditorSetting.load()

        // TextContainer
        let textContainer = NSTextContainer()

        // LayoutManager
        let editorLayoutManager = EditorLayoutManager()
        editorLayoutManager.set(editorSetting: editorSetting)
        editorLayoutManager.set(codeStyle: codeStyle)
        editorLayoutManager.addTextContainer(textContainer)
        self.editorLayoutManager = editorLayoutManager

        // TextStorage
        let editorTextStorage = EditorTextStorage()
        editorTextStorage.set(codeStyle: codeStyle)
        editorTextStorage.set(tokens: SyntaxLoader.tokens(fileExtension: fileExtension, codeStyle: codeStyle))
        editorTextStorage.addLayoutManager(editorLayoutManager)
        self.editorTextStorage = editorTextStorage

        // EditorView
        let editorView = EditorView(frame: .zero, textContainer: textContainer)
        editorView.set(editorSetting: editorSetting)
        editorView.set(codeStyle: codeStyle)
        editorView.controller = self
        editorView.delegate = self
        self.editorView = editorView
        self.view = editorView

        // NotificationCenter
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)

        // UndoManager
        let editorUndoManager = EditorUndoManager()
        editorUndoManager.editorView = editorView
        self.editorUndoManager = editorUndoManager
    }

    @objc func refreshCodeStyle() {
        guard let editorView = view as? EditorView else {
            return
        }
        let codeStyle = CodeStyle.load()
        editorView.set(codeStyle: codeStyle)
        editorTextStorage.set(codeStyle: codeStyle)
        editorTextStorage.set(tokens: SyntaxLoader.tokens(fileExtension: fileExtension, codeStyle: codeStyle))
        editorLayoutManager.set(codeStyle: codeStyle)
    }


    // MARK: - Command
    override var keyCommands: [UIKeyCommand]? {
        [
            // aaaa
            UIKeyCommand(input: "", modifierFlags: [.command], action: #selector(_commitEdit)),
            // Comment out
            UIKeyCommand(input: "/", modifierFlags: [.command], action: #selector(_commitEdit)),
            // Deindent
            UIKeyCommand(input: "\t", modifierFlags: [.shift], action: #selector(deindent)),
            // Completion request
            UIKeyCommand(input: " ", modifierFlags: [.alternate], action: #selector(requestCompletion)),
        ]
    }



    var completionTrigger = ["d", "k"]

    var rule: EditRule = EditRule()
    var status: EditStatus = EditStatus()
    static let newLine = try! NSRegularExpression(pattern: "\n", options: [])

}


// MARK: - Source code edit support

extension EditorViewController: UITextViewDelegate {

    struct EditRule {
        var useHardTab: Bool = false
        var tabSize: Int = 4
        var indent: String = "    "
    }

    struct EditStatus {
        var currentChange: ChangeReason = .selection
        var previousChange: ChangeReason = .selection
        var location: Int = -1
        var beforeText: String = ""
        var afterText: String = ""
        var needCommit: Bool = false
        var needCompletion: Bool = false

        var hasEditorialContent: Bool {
            !(beforeText.isEmpty && afterText.isEmpty)
        }

        mutating func setCommit(location: Int, before: String, after: String) {
            self.location = location
            self.beforeText = before
            self.afterText = after
            self.needCommit = true
        }

        mutating func clear() {
            self.location = -1
            self.beforeText = ""
            self.afterText = ""
            self.needCommit = false
        }
    }

    enum ChangeReason {
        case word
        case nonWord
        case newLine
        case indent
        case delete
        case replace
        case selection

        private static let nonWordRegex = try! NSRegularExpression(pattern: "\\W", options: [])

        static func get(_ range: NSRange, _ text: String) -> Self {
            if text.isEmpty {
                return range.length == 1 ? .delete : .replace

            } else if text.count == 1 {
                if text == .lineFeed {
                    return .newLine
                } else if range.length >= 1 && text == .tab {
                    return .indent
                } else if nonWordRegex.firstMatch(in: text, options: [], range: text.range) != nil {
                    return .nonWord
                } else {
                    return .word
                }

            } else {
                return .replace
            }
        }
    }


    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard editorView.markedTextRange == nil else {
            return true
        }

        status.currentChange = ChangeReason.get(range, text)

        if status.currentChange == .replace {
            let fullText = editorTextStorage.string as NSString
            let beforeText = range.length == 0 ? "" : fullText.substring(with: range)
            status.setCommit(location: range.location, before: beforeText, after: text)

        } else if status.currentChange == .indent {
            let fullText = editorTextStorage.string as NSString
            let lineRange = fullText.lineRange(for: range)
            let beforeText = fullText.substring(with: lineRange)
            var afterText = ""
            beforeText.enumerateLines(regex: Self.newLine) {
                afterText.append($0.addIndent(with: self.rule.indent))
            }
            editorTextStorage.replaceCharacters(in: lineRange, with: afterText)
            editorView.selectedRange = NSMakeRange(lineRange.location, afterText.length)
            status.setCommit(location: lineRange.location, before: beforeText, after: afterText)
            return false

        } else {
            let replacement = replacementText(range, text) ?? text
            if status.afterText.isEmpty {
                status.location = range.location
                status.afterText = replacement
            } else {
                status.afterText.append(replacement)
            }

            if completionTrigger.contains(replacement) {
                status.needCommit = true
                status.needCompletion = true

            } else if status.previousChange == .word && status.currentChange != .word
                    || status.previousChange != .newLine && status.currentChange == .newLine
                    || status.previousChange != .delete && status.currentChange == .delete {
                status.needCommit = true
            }

            if replacement != text {
                editorTextStorage.replaceCharacters(in: range, with: replacement)
                editorView.selectedRange = NSMakeRange(range.location + replacement.length, 0)
                return false
            }
        }

        return true
    }


    private func replacementText(_ range: NSRange, _ text: String) -> String? {
        if text == "\t" {
            if rule.useHardTab {
                return nil

            } else {
                let fullText = editorTextStorage.string as NSString
                let lineLocation = fullText.lineRange(for: range).location
                let lineRange = NSMakeRange(lineLocation, range.location - lineLocation)
                let count = rule.tabSize - fullText.substring(with: lineRange).monospaceCount % rule.tabSize
                return Array(repeating: " ", count: count).joined()
            }
        }
        return nil
    }


    func textViewDidChangeSelection(_ textView: UITextView) {
        print(#function)
        guard editorView.markedTextRange == nil else {
            return
        }

        if status.needCommit {
            commitUndoHistory()
            commitEditorialContents()
            status.clear()

        } else if status.hasEditorialContent && status.previousChange != .selection && status.currentChange == .selection {
            status.needCommit = true
            commitUndoHistory()
            commitEditorialContents()
            status.clear()
        }

        if status.needCompletion {
            requestCompletion()
        }

        status.previousChange = status.currentChange
        status.currentChange = .selection
    }


    func textViewDidEndEditing(_ textView: UITextView) {
        guard status.hasEditorialContent else {
            return
        }
        commitUndoHistory()
        commitEditorialContents()
        status.clear()
    }


    @objc func deindent() {
        let fullText = editorTextStorage.string as NSString
        let lineRange = fullText.lineRange(for: editorView.selectedRange)
        let beforeText = fullText.substring(with: lineRange)
        var afterText = ""
        beforeText.enumerateLines(regex: Self.newLine) {
            if let line = $0.removeIndent(with: self.rule.indent) {
                afterText.append(contentsOf: line)
            } else {
                afterText.append($0)
            }
        }
        if beforeText == afterText {
            return
        }
        status.currentChange = .indent
        editorTextStorage.replaceCharacters(in: lineRange, with: afterText)
        editorView.selectedRange = NSMakeRange(lineRange.location, afterText.length)
        status.setCommit(location: lineRange.location, before: beforeText, after: afterText)
        commitUndoHistory()
        commitEditorialContents()
        status.clear()
    }

    @objc func _commitEdit() {
        guard status.hasEditorialContent else {
            return
        }
        commitUndoHistory()
        commitEditorialContents()
        status.clear()
    }


    private func commitUndoHistory() {
        // Commit to UndoManager
        editorUndoManager.appendHistory(location: status.location, before: status.beforeText, after: status.afterText)
        editorUndoManager.registerUndo()
    }

}


// MARK: - Undo/Redo support

extension EditorViewController {

    func undo() {
        guard let editHistory = editorUndoManager.editHistory else {
            return
        }
        editorUndoManager.registerRedo()
        status.currentChange = .replace
        let range = NSMakeRange(editHistory.location, editHistory.after.length)
        editorTextStorage.replaceCharacters(in: range, with: editHistory.before)
        editorView.selectedRange = NSMakeRange(range.location, 0)
        status.setCommit(location: range.location, before: editHistory.after, after: editHistory.before)
        commitEditorialContents()
        status.clear()
    }

    func redo() {
        guard let editHistory = editorUndoManager.editHistory else {
            return
        }
        editorUndoManager.registerUndo()
        status.currentChange = .replace
        let range = NSMakeRange(editHistory.location, editHistory.before.length)
        editorTextStorage.replaceCharacters(in: range, with: editHistory.after)
        editorView.selectedRange = NSMakeRange(range.location + editHistory.after.length, 0)
        status.setCommit(location: range.location, before: editHistory.before, after: editHistory.after)
        commitEditorialContents()
        status.clear()
    }

}


// MARK: - Language server support

extension EditorViewController: TextDocumentMessageDelegate {

    func commitEditorialContents() {
        print("\(status.location): \"\(status.beforeText)\" -> \"\(status.afterText)\"")
    }

    @objc func requestCompletion() {
        print(#function)
        status.needCompletion = false
    }

    func completion(id: RequestID, result: Result<CompletionList?, ErrorResponse>) {
        guard requestId != id else {
            return
        }
    }

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
