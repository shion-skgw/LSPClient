//
//  MessageMethod.swift
//  LSPClient
//
//  Created by Shion on 2020/06/10.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Application level

let CANCEL_REQUEST = "$/cancelRequest"
let INITIALIZE = "initialize"
let INITIALIZED = "initialized"
let SHUTDOWN = "shutdown"
let EXIT = "exit"
let WINDOW_SHOW_MESSAGE = "window/showMessage"
let WINDOW_SHOW_MESSAGE_REQUEST = "window/showMessageRequest"
let WINDOW_LOG_MESSAGE = "window/logMessage"


// MARK: - Workspace level

let WORKSPACE_DID_CHANGE_CONFIGURATION = "workspace/didChangeConfiguration"
let WORKSPACE_DID_CHANGE_WATCHED_FILES = "workspace/didChangeWatchedFiles"
let WORKSPACE_SYMBOL = "workspace/symbol"
let WORKSPACE_EXECUTE_COMMAND = "workspace/executeCommand"
let WORKSPACE_APPLY_EDIT = "workspace/applyEdit"


// MARK: - TextDocument level

let TEXT_DOCUMENT_DID_OPEN = "textDocument/didOpen"
let TEXT_DOCUMENT_DID_CHANGE = "textDocument/didChange"
let TEXT_DOCUMENT_DID_SAVE = "textDocument/didSave"
let TEXT_DOCUMENT_DID_CLOSE = "textDocument/didClose"
let TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS = "textDocument/publishDiagnostics"
let TEXT_DOCUMENT_COMPLETION = "textDocument/completion"
let COMPLETION_ITEM_RESOLVE = "completionItem/resolve"
let TEXT_DOCUMENT_HOVER = "textDocument/hover"
let TEXT_DOCUMENT_DEFINITION = "textDocument/definition"
let TEXT_DOCUMENT_TYPE_DEFINITION = "textDocument/typeDefinition"
let TEXT_DOCUMENT_IMPLEMENTATION = "textDocument/implementation"
let TEXT_DOCUMENT_REFERENCES = "textDocument/references"
let TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT = "textDocument/documentHighlight"
let TEXT_DOCUMENT_DOCUMENT_SYMBOL = "textDocument/documentSymbol"
let TEXT_DOCUMENT_CODE_ACTION = "textDocument/codeAction"
let TEXT_DOCUMENT_RANGE_FORMATTING = "textDocument/rangeFormatting"
let TEXT_DOCUMENT_RENAME = "textDocument/rename"


// MARK: - Type definition

let REQUEST_PARAMS_TYPE: [String: RequestParamsType.Type] = [
	WINDOW_SHOW_MESSAGE_REQUEST: ShowMessageRequestParams.self,
	WORKSPACE_APPLY_EDIT: ApplyWorkspaceEditParams.self,
]

let NOTIFICATION_PARAMS_TYPE: [String: NotificationParamsType.Type] = [
	CANCEL_REQUEST: CancelParams.self,
	WINDOW_SHOW_MESSAGE: ShowMessageParams.self,
	WINDOW_LOG_MESSAGE: LogMessageParams.self,
	TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS: PublishDiagnosticsParams.self,
]

let RESPONSE_RESULT_TYPE: [String: ResultType.Type] = [
	INITIALIZE: InitializeResult.self,
	SHUTDOWN: VoidValue?.self,
	WORKSPACE_SYMBOL: [SymbolInformation]?.self,
	WORKSPACE_EXECUTE_COMMAND: AnyValue?.self,
	TEXT_DOCUMENT_COMPLETION: CompletionList?.self,
	COMPLETION_ITEM_RESOLVE: CompletionItem.self,
	TEXT_DOCUMENT_HOVER: Hover?.self,
//	TEXT_DOCUMENT_DECLARATION: FindLocationResult?.self,
	TEXT_DOCUMENT_DEFINITION: FindLocationResult?.self,
	TEXT_DOCUMENT_TYPE_DEFINITION: FindLocationResult?.self,
	TEXT_DOCUMENT_IMPLEMENTATION: FindLocationResult?.self,
	TEXT_DOCUMENT_REFERENCES: [Location]?.self,
	TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT: [DocumentHighlight]?.self,
	TEXT_DOCUMENT_DOCUMENT_SYMBOL: [SymbolInformation]?.self,
	TEXT_DOCUMENT_CODE_ACTION: CodeActionResult?.self,
//	TEXT_DOCUMENT_FORMATTING: [TextEdit]?.self,
	TEXT_DOCUMENT_RANGE_FORMATTING: [TextEdit]?.self,
	TEXT_DOCUMENT_RENAME: WorkspaceEdit?.self,
]
