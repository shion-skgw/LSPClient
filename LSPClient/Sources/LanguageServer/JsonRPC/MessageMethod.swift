//
//  MessageMethod.swift
//  LSPClient
//
//  Created by Shion on 2020/06/10.
//  Copyright © 2020 Shion. All rights reserved.
//

enum MessageMethod: String, Codable {
    // MARK: - Application level
    case cancelRequest = "$/cancelRequest"
    case initialize = "initialize"
    case initialized = "initialized"
    case shutdown = "shutdown"
    case exit = "exit"
    case windowShowMessage = "window/showMessage"
    case windowShowMessageRequest = "window/showMessageRequest"
    case windowLogMessage = "window/logMessage"

    // MARK: - Workspace level
    case workspaceDidChangeConfiguration = "workspace/didChangeConfiguration"
    case workspaceDidChangeWatchedFiles = "workspace/didChangeWatchedFiles"
    case workspaceSymbol = "workspace/symbol"
    case workspaceExecuteCommand = "workspace/executeCommand"
    case workspaceApplyEdit = "workspace/applyEdit"

    // MARK: - TextDocument level
    case textDocumentDidOpen = "textDocument/didOpen"
    case textDocumentDidChange = "textDocument/didChange"
    case textDocumentDidSave = "textDocument/didSave"
    case textDocumentDidClose = "textDocument/didClose"
    case textDocumentPublishDiagnostics = "textDocument/publishDiagnostics"
    case textDocumentCompletion = "textDocument/completion"
    case completionItemResolve = "completionItem/resolve"
    case textDocumentHover = "textDocument/hover"
    case textDocumentDefinition = "textDocument/definition"
    case textDocumentTypeDefinition = "textDocument/typeDefinition"
    case textDocumentImplementation = "textDocument/implementation"
    case textDocumentReferences = "textDocument/references"
    case textDocumentDocumentHighlight = "textDocument/documentHighlight"
    case textDocumentDocumentSymbol = "textDocument/documentSymbol"
    case textDocumentCodeAction = "textDocument/codeAction"
    case textDocumentRangeFormatting = "textDocument/rangeFormatting"
    case textDocumentRename = "textDocument/rename"

    // MARK: - Unsupported
    case unsupported

    var requestParamsType: RequestParamsType.Type? {
        REQUEST_PARAMS_TYPE[self]
    }

    var notificationParamsType: NotificationParamsType.Type? {
        NOTIFICATION_PARAMS_TYPE[self]
    }

    var responseResultType: ResultType.Type? {
        RESPONSE_RESULT_TYPE[self]
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        let value = try container.decode(String.self)
        self = MessageMethod(rawValue: value) ?? .unsupported
    }

}

private let REQUEST_PARAMS_TYPE: [MessageMethod: RequestParamsType.Type] = [
    .windowShowMessageRequest: ShowMessageRequestParams.self,
    .workspaceApplyEdit: ApplyWorkspaceEditParams.self,
]

private let NOTIFICATION_PARAMS_TYPE: [MessageMethod: NotificationParamsType.Type] = [
    .cancelRequest: CancelParams.self,
    .windowShowMessage: ShowMessageParams.self,
    .windowLogMessage: LogMessageParams.self,
    .textDocumentPublishDiagnostics: PublishDiagnosticsParams.self,
]

private let RESPONSE_RESULT_TYPE: [MessageMethod: ResultType.Type] = [
    .initialize: InitializeResult.self,
    .shutdown: VoidValue?.self,
    .workspaceSymbol: [SymbolInformation]?.self,
    .workspaceExecuteCommand: AnyValue?.self,
    .textDocumentCompletion: CompletionList?.self,
    .completionItemResolve: CompletionItem.self,
    .textDocumentHover: Hover?.self,
//    .textDocumentDeclaration: FindLocationResult?.self,
    .textDocumentDefinition: FindLocationResult?.self,
    .textDocumentTypeDefinition: FindLocationResult?.self,
    .textDocumentImplementation: FindLocationResult?.self,
    .textDocumentReferences: [Location]?.self,
    .textDocumentDocumentHighlight: [DocumentHighlight]?.self,
    .textDocumentDocumentSymbol: [SymbolInformation]?.self,
    .textDocumentCodeAction: CodeActionResult?.self,
//    .textDocumentFormatting: [TextEdit]?.self,
    .textDocumentRangeFormatting: [TextEdit]?.self,
    .textDocumentRename: WorkspaceEdit?.self,
]
