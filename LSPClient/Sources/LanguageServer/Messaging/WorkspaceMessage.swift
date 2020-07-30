//
//  WorkspaceMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

final class WorkspaceMessage {

	static let shared: WorkspaceMessage = WorkspaceMessage()
	private unowned var messageManager: MessageManager = MessageManager.shared

	private init() {}

	func didChangeConfiguration(params: DidChangeConfigurationParams) {
		let message = Message.notification(WORKSPACE_DID_CHANGE_CONFIGURATION, params)
		messageManager.send(message: message)
	}

	func didChangeWatchedFiles(params: DidChangeWatchedFilesParams) {
		let message = Message.notification(WORKSPACE_DID_CHANGE_WATCHED_FILES, params)
		messageManager.send(message: message)
	}

	func symbol(params: WorkspaceSymbolParams, source: WorkspaceResponceDelegate) -> RequestID {
		let context = RequestContext(method: WORKSPACE_SYMBOL, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func executeCommand(params: ExecuteCommandParams, source: WorkspaceResponceDelegate) -> RequestID {
		let context = RequestContext(method: WORKSPACE_EXECUTE_COMMAND, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func applyEdit(params: ApplyWorkspaceEditParams, source: WorkspaceResponceDelegate) -> RequestID {
		let context = RequestContext(method: WORKSPACE_APPLY_EDIT, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

}

protocol WorkspaceResponceDelegate: ResponceDelegate {

	func symbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>)
	func executeCommand(id: RequestID, result: Result<AnyValue?, ErrorResponse>)

}

extension WorkspaceResponceDelegate {

	func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
		guard let source = context.source as? WorkspaceResponceDelegate else {
			fatalError()
		}

		switch context.method {
		case WORKSPACE_SYMBOL:
			source.symbol(id: id, result: or(result, error))
		case WORKSPACE_EXECUTE_COMMAND:
			source.executeCommand(id: id, result: or(result, error))
		default:
			throw MessageDecodingError.unsupportedMethod(id, context.method)
		}

		return true
	}

}
