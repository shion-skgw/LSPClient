//
//  EditorViewController.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController, UITextViewDelegate {

    var uri: DocumentUri!
    private var requestId: RequestID?
    private weak var editorTextStorage: EditorTextStorage!
    private weak var editorLayoutManager: EditorLayoutManager!

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
        editorTextStorage.set(tokens: SyntaxLoader.tokens(fileExtension: "swift", codeStyle: codeStyle))
        editorTextStorage.addLayoutManager(editorLayoutManager)
        self.editorTextStorage = editorTextStorage

        // EditorView
        let editorView = EditorView(frame: .zero, textContainer: textContainer)
        editorView.set(editorSetting: editorSetting)
        editorView.set(codeStyle: codeStyle)
        editorView.controller = self
        editorView.delegate = self
        self.view = editorView

        // NotificationCenter
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)

        // UndoManager
        undoManager?.registerUndo(withTarget: editorView, selector: #selector(editorView.undo), object: nil)
    }

    @objc func refreshCodeStyle() {
        guard let editorView = view as? EditorView else {
            return
        }
        let codeStyle = CodeStyle.load()
        editorView.set(codeStyle: codeStyle)
        editorTextStorage.set(codeStyle: codeStyle)
        editorTextStorage.set(tokens: SyntaxLoader.tokens(fileExtension: "swift", codeStyle: codeStyle))
        editorLayoutManager.set(codeStyle: codeStyle)
    }



    // MARK: - Command
    override var keyCommands: [UIKeyCommand]? {
        return [
            UIKeyCommand(input: "\t", modifierFlags: [.shift], action: #selector(deindent(_:))),
            UIKeyCommand(input: " ", modifierFlags: [.alternate], action: #selector(completion(_:))),
        ]
    }

    @objc func deindent(_ sender: UIKeyCommand) {
        print(#function)
    }

    @objc func completion(_ sender: UIKeyCommand) {
        print(#function)
    }


    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Editing

    private let nonWord = try! NSRegularExpression(pattern: "\\W", options: [])

    var currentChangeReason: ChangeReason = .changeSelection
    var previousChangeReason: ChangeReason = .changeSelection
    var completionTrigger = ["あ"]
    var needCommit = false


    struct EditHistory {
        var range: NSRange
        var text: String
//        var scrollPoint: CGPoint
    }
    var currentVersion = 1
    var editHistories: [EditHistory] = [
        EditHistory(range: NSMakeRange(0, 0), text: "")
    ]

    var editLocation: Int = -1
    var editLength: Int = 0
    var editText: String = ""

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        guard textView.markedTextRange == nil else {
            return true
        }

        currentChangeReason = changeReason(range, text)

        if completionTrigger.contains(text) {
            needCommit = true
        } else if previousChangeReason == .word && currentChangeReason != .word {
            needCommit = true
        } else if previousChangeReason != .newLine && currentChangeReason == .newLine {
            needCommit = true
        } else if previousChangeReason != .delete && currentChangeReason == .delete {
            needCommit = true
        } else if currentChangeReason == .paste {
            needCommit = true
        } else if currentChangeReason == .cut {
            needCommit = true
        }

        if editText.isEmpty {
            editLocation = range.location
            editLength = text.range.length
            editText = text
        } else {
            editLength += text.range.length
            editText += text
        }

        if editHistories.count > currentVersion {
            editHistories.removeLast(editHistories.count - currentVersion)
            currentVersion = editHistories.count
        }

        return true
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        guard let editorView = view as? EditorView, editorView.markedTextRange == nil else {
            return
        }

        if needCommit || previousChangeReason != .changeSelection && currentChangeReason == .changeSelection {
            commitEditHistory()
            undoManager?.registerUndo(withTarget: editorView, selector: #selector(editorView.undo), object: nil)
            needCommit = false
            editText = ""
        }

        previousChangeReason = currentChangeReason
        currentChangeReason = .changeSelection
    }

    func commitEditHistory() {
        guard !editText.isEmpty else {
            return
        }
        let range = NSMakeRange(editLocation, editLength)
        let editHistory = EditHistory(range: range, text: editText)
        editHistories.append(editHistory)
        currentVersion = editHistories.count
        print(editHistory)
    }

    func undo() {
        guard let editorView = view as? EditorView, let undoManager = self.undoManager, undoManager.canUndo else {
            print("can't undo")
            return
        }

        commitEditHistory()
        undoManager.registerUndo(withTarget: editorView, selector: #selector(editorView.redo), object: nil)

        currentVersion -= 1
        let editHistory = editHistories[currentVersion]
        currentChangeReason = .cut
        editText = ""

        editorTextStorage.replaceCharacters(in: editHistory.range, with: "")
        editorView.selectedRange = NSMakeRange(editHistory.range.location, 0)
    }

    func redo() {
        guard let editorView = view as? EditorView, let undoManager = self.undoManager, undoManager.canRedo else {
            print("can't redo")
            return
        }
        undoManager.registerUndo(withTarget: editorView, selector: #selector(editorView.undo), object: nil)

        let editHistory = editHistories[currentVersion]
        currentVersion += 1
        currentChangeReason = .paste
        editText = ""
        editorTextStorage.replaceCharacters(in: NSMakeRange(editHistory.range.location, 0), with: editHistory.text)
        editorView.selectedRange = NSMakeRange(editHistory.range.upperBound, 0)
    }

    enum ChangeReason {
        case word
        case nonWord
        case newLine
        case indent
        case deindent
        case delete
        case paste
        case cut
        case changeSelection
    }

    private func changeReason(_ range: NSRange, _ text: String) -> ChangeReason {
        if text.isEmpty {
            return range.length == 1 ? .delete : .cut
        } else if text.count >= 2 {
            return .paste
        } else {
            if range.length > 1 && text == .tab {
                return .indent
            } else if text == .lineFeed {
                return .newLine
            } else if nonWord.firstMatch(in: text, options: [], range: text.range) != nil {
                return .nonWord
            } else {
                return .word
            }
        }
    }



}


extension EditorViewController: TextDocumentMessageDelegate {

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
