//
//  EditorViewController.swift
//  LSPClient
//
//  Created by Shion on 2020/08/12.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

final class EditorViewController: UIViewController {

    private var requestId: RequestID?
    private weak var lineTable: LineTable!

    override func loadView() {
        super.loadView()

        // TextContainer
        let textContainer = NSTextContainer()

        // LayoutManager
        let layoutManager = LayoutManager()
        layoutManager.set(editorSetting: EditorSetting.load())
        layoutManager.set(codeStyle: CodeStyle.load())
        layoutManager.addTextContainer(textContainer)

        // TextStorage
        let textStorage = TextStorage()
        textStorage.set(codeStyle: CodeStyle.load())
        textStorage.set(tokens: SyntaxLoader.tokens(fileExtension: "swift"))
        textStorage.addLayoutManager(layoutManager)

        // EditorView
        let editorView = EditorView(textContainer: textContainer)
        editorView.set(editorSetting: EditorSetting.load())
        editorView.set(codeStyle: CodeStyle.load())

        // Initialize
        self.view = editorView
        self.lineTable = textStorage.lineTable
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        view.frame = CGRect(x: 100, y: 50, width: 200, height: 300)
    }

}

extension EditorViewController: UITextViewDelegate {

    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        let textDocument = TextDocumentIdentifier(uri: URL(string: "")!)
        let position = lineTable.position(for: range.location)!
        let params = CompletionParams(textDocument: textDocument, position: position, context: nil)
        requestId = completion(params: params)

        let textDocument_ = VersionedTextDocumentIdentifier(uri: URL(string: "")!, version: RequiredValue(1))
        let params_ = DidChangeTextDocumentParams(textDocument: textDocument_, contentChanges: [])
        didChange(params: params_)
        return true
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
