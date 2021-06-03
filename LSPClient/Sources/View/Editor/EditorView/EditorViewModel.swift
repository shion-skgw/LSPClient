//
//  EditorViewModel.swift
//  LSPClient
//
//  Created by Shion on 2021/06/03.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class EditorViewModel: TextDocumentMessageDelegate {
    /// EditorViewController
    weak var controller: EditorViewController!
    /// SyntaxManager
    weak var syntaxManager: SyntaxManager?
    /// Language server capabilities
    private let serverCapability: ServerCapability

    var currentRequestID: RequestID?
    private var currentVersion: Int = 1
    private var beforeChangesText: String = ""

    var documentUri: DocumentUri {
        self.controller.uri
    }

    init() {
        self.serverCapability = ServerCapability.load()
    }

    func responseError(id: RequestID, method: MessageMethod, error: ErrorResponse) {
    }

}


// MARK: - File change event support

extension EditorViewModel {

    func sendDidOpen(_ editorView: EditorView) {
        guard serverCapability.textDocumentSync.openClose else {
            return
        }

        // Generate parameters
        let languageId = LanguageID.of(fileExtension: documentUri.pathExtension)
        let textDocument = TextDocumentItem(uri: documentUri, languageId: languageId, version: currentVersion, text: editorView.text)
        let didOpenParams = DidOpenTextDocumentParams(textDocument: textDocument)

        // Send notification "textDocument/didOpen"
        didOpen(params: didOpenParams)

        // Update status
        beforeChangesText = editorView.text
    }

    func needCommitChanges(current: String, last: String) -> Bool {
        return current != last && !(syntaxManager?.word(text: current) ?? false)
    }

    func sendDidChange(_ editorView: EditorView) {
        guard editorView.text != beforeChangesText else {
            return
        }

        // Send notification
        switch serverCapability.textDocumentSync.change {
        case .none:
            break
        case .full:
            sendDidChangeFull(current: editorView.text)
        case .incremental:
            sendDidChangeIncremental(current: editorView.text)
        }

        // Update status
        beforeChangesText = editorView.text
        controller.didSendDidChange()
    }

    private func sendDidChangeFull(current text: String) {
        // Generate parameters
        currentVersion += 1
        let textDocument = VersionedTextDocumentIdentifier(uri: documentUri, version: currentVersion)
        let contentChange = TextDocumentContentChangeEvent.full(text)
        let didChangeParams = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [contentChange])

        // Send notification "textDocument/didChange"
        didChange(params: didChangeParams)
    }

    private func sendDidChangeIncremental(current text: String) {
        // Get the changes
        let changes = text.changes(from: beforeChangesText)

        // Generate parameters
        currentVersion += 1
        let textDocument = VersionedTextDocumentIdentifier(uri: documentUri, version: currentVersion)
        let range = TextRange(changes.range, in: beforeChangesText)
        let contentChange = TextDocumentContentChangeEvent.incremental(range, changes.text)
        let didChangeParams = DidChangeTextDocumentParams(textDocument: textDocument, contentChanges: [contentChange])

        // Send notification "textDocument/didChange"
        didChange(params: didChangeParams)
    }

    func sendDidSave(_ editorView: EditorView) {

    }

    func sendDidClose(_ editorView: EditorView) {

    }

}


// MARK: - Completion support

extension EditorViewModel {

    func needCompletion(_ inputText: String) -> Bool {
        return inputText.contains(characterSet: serverCapability.completion.triggerCharacters)
    }

    func needCommitCompletion(_ inputText: String) -> Bool {
        return inputText.contains(characterSet: serverCapability.completion.allCommitCharacters)
    }

    func sendCompletion(_ editorView: EditorView, trigger: String?) {
        guard serverCapability.completion.isSupport else {
            return
        }

        // Get filter text
        if let range = syntaxManager?.wordRange(text: editorView.text, range: editorView.selectedRange) {
            controller.willSendCompletion(invoke: editorView.selectedRange, filter: editorView.text[range])
        } else {
            controller.willSendCompletion(invoke: editorView.selectedRange, filter: "")
        }

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: documentUri)
        let position = TextPosition(editorView.selectedRange, in: editorView.text)
        let context = CompletionContext(triggerKind: trigger == nil ? .invoked : .triggerCharacter, triggerCharacter: trigger)
        let completionParams = CompletionParams(textDocument: textDocument, position: position, context: context)

        // Send request "textDocument/completion"
        currentRequestID = completion(params: completionParams)

        controller.didSendCompletion()
    }

    func completion(id: RequestID, result: CompletionList?) {
        guard let result = result, result.items.isNotEmpty else {
            return
        }
        controller.showCompletion(result: result)
    }

    func sendCompletionResolve(_ editorView: EditorView) {}

    func completionResolve(id: RequestID, result: CompletionItem) {}

}


// MARK: - Hover support

extension EditorViewModel {

    func sendHover(_ editorView: EditorView) {
        guard serverCapability.hover.isSupport else {
            return
        }

        controller.willSendHover(invoke: editorView.selectedRange)

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: documentUri)
        let position = TextPosition(editorView.selectedRange, in: editorView.text)
        let hoverParams = HoverParams(textDocument: textDocument, position: position)

        // Send request
        currentRequestID = hover(params: hoverParams)
    }

    func hover(id: RequestID, result: Hover?) {
        guard let result = result, result.contents.value.isNotEmpty else {
            return
        }
        controller.showHover(result: result)
    }

}


// MARK: - Signature help support

extension EditorViewModel {

    func needSignatureHelp(_ inputText: String) -> Bool {
        return inputText.contains(characterSet: serverCapability.signatureHelp.triggerCharacters)
    }

    func sendSignatureHelp(_ editorView: EditorView, trigger: String?) {
        guard serverCapability.signatureHelp.isSupport else {
            return
        }

        controller.willSendSignatureHelp(invoke: editorView.selectedRange)

        // Generate parameters
        let textDocument = TextDocumentIdentifier(uri: documentUri)
        let position = TextPosition(editorView.selectedRange, in: editorView.text)
        let context = SignatureHelpContext(triggerKind: .triggerCharacter, triggerCharacter: trigger, isRetrigger: false, activeSignatureHelp: nil)
        let signatureHelpParams = SignatureHelpParams(textDocument: textDocument, position: position, context: context)

        // Send request
        currentRequestID = signatureHelp(params: signatureHelpParams)

        // Update status
        controller.didSendSignatureHelp()
    }

    func signatureHelp(id: RequestID, result: SignatureHelp?) {
        guard let result = result, result.signatures.isNotEmpty else {
            return
        }
        controller.showSignatureHelp(result: result)
    }

}


// MARK: - Find location support

extension EditorViewModel {

//    func sendDeclaration(_ editorView: EditorView) {}
//    func declaration(id: RequestID, result: FindLocationResult?) {}
    func sendDefinition(_ editorView: EditorView) {}
    func definition(id: RequestID, result: FindLocationResult?) {}
    func sendTypeDefinition(_ editorView: EditorView) {}
    func typeDefinition(id: RequestID, result: FindLocationResult?) {}
    func sendImplementation(_ editorView: EditorView) {}
    func implementation(id: RequestID, result: FindLocationResult?) {}
    func sendReferences(_ editorView: EditorView) {}
    func references(id: RequestID, result: [Location]?) {}

}


// MARK: - Document highlight support

extension EditorViewModel {

    func sendDocumentHighlight(_ editorView: EditorView) {}
    func documentHighlight(id: RequestID, result: [DocumentHighlight]?) {}

}


// MARK: - Document symbol support

extension EditorViewModel {

    func sendDocumentSymbol(_ editorView: EditorView) {}
    func documentSymbol(id: RequestID, result: [SymbolInformation]?) {}

}


// MARK: - Code action support

extension EditorViewModel {

    func sendCodeAction(_ editorView: EditorView) {}
    func codeAction(id: RequestID, result: CodeActionResult?) {}

}


// MARK: - Formatting support

extension EditorViewModel {

//    func sendFormatting(_ editorView: EditorView) {}
//    func formatting(id: RequestID, result: [TextEdit]?) {}
    func sendRangeFormatting(_ editorView: EditorView) {}
    func rangeFormatting(id: RequestID, result: [TextEdit]?) {}

}


// MARK: - Rename support

extension EditorViewModel {

    func sendRename(_ editorView: EditorView) {}
    func rename(id: RequestID, result: WorkspaceEdit?) {}

}
