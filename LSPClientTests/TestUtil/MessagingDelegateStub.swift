//
//  MessagingDelegateStub.swift
//  LSPClientTests
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import XCTest
import Foundation
@testable import LSPClient

class MessageManagerDelegateStub: MessageManagerDelegate {
    var function: String!
    var cause: Error!
    var message: Message!
    var params: ParamsType!
    var id: RequestID!

    func messageParseError(cause: Error, message: Message?) {
        self.function = #function
        self.cause = cause
        self.message = message
    }

    func connectionError(cause: Error) {
        self.function = #function
        self.cause = cause
    }

    func cancelRequest(params: CancelParams) {
        self.function = #function
        self.params = params
    }

    func showMessage(params: ShowMessageParams) {
        self.function = #function
        self.params = params
    }

    func showMessageRequest(id: RequestID, params: ShowMessageRequestParams) {
        self.function = #function
        self.params = params
        self.id = id
    }

    func logMessage(params: LogMessageParams) {
        self.function = #function
        self.params = params
    }

    func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams) {
        self.function = #function
        self.params = params
        self.id = id
    }

    func publishDiagnostics(params: PublishDiagnosticsParams) {
        self.function = #function
        self.params = params
    }

}

class WorkspaceMessageDelegateStub: WorkspaceMessageDelegate {
    var function: String!
    var result: ResultType!
    var error: ErrorResponse!
    var id: RequestID!
    var isSuccess: Bool!

    func initialize(id: RequestID, result: InitializeResult) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func shutdown(id: RequestID, result: VoidValue?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func symbol(id: RequestID, result: [SymbolInformation]?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func executeCommand(id: RequestID, result: AnyValue?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func responseError(id: RequestID, method: MessageMethod, error: ErrorResponse) {
        self.function = #function
        self.error = error
        self.id = id
    }

}

class TextDocumentMessageDelegateStub: TextDocumentMessageDelegate {
    var function: String!
    var result: ResultType!
    var error: ErrorResponse!
    var id: RequestID!
    var isSuccess: Bool!

    func completion(id: RequestID, result: CompletionList?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func completionResolve(id: RequestID, result: CompletionItem) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func hover(id: RequestID, result: Hover?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func definition(id: RequestID, result: FindLocationResult?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func typeDefinition(id: RequestID, result: FindLocationResult?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func implementation(id: RequestID, result: FindLocationResult?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func references(id: RequestID, result: [Location]?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func documentHighlight(id: RequestID, result: [DocumentHighlight]?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func documentSymbol(id: RequestID, result: [SymbolInformation]?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func codeAction(id: RequestID, result: CodeActionResult?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func rangeFormatting(id: RequestID, result: [TextEdit]?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func rename(id: RequestID, result: WorkspaceEdit?) {
        self.function = #function
        self.result = result
        self.isSuccess = true
        self.id = id
    }

    func responseError(id: RequestID, method: MessageMethod, error: ErrorResponse) {
        self.function = #function
        self.error = error
        self.id = id
    }

}
