//
//  ServerMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

protocol ServerMessageDelegate: class {

	func codingError(cause: Error, message: Message?)
	func connectionError(cause: Error)
	func showMessage(params: ShowMessageParams)
	func showMessageRequest(id: RequestID, params: ShowMessageRequestParams)
	func logMessage(params: LogMessageParams)
	func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams)
	func publishDiagnostics(params: PublishDiagnosticsParams)

}

extension ServerMessageDelegate {

	func receiveRequest(id: RequestID, method: String, params: RequestParamsType) {
		switch method {
		case WINDOW_SHOW_MESSAGE_REQUEST:
			showMessageRequest(id: id, params: params as! ShowMessageRequestParams)
		case WORKSPACE_APPLY_EDIT:
			applyEdit(id: id, params: params as! ApplyWorkspaceEditParams)
		default:
			fatalError()
		}
	}

	func receiveNotification(method: String, params: NotificationParamsType) {
		switch method {
		case WINDOW_SHOW_MESSAGE:
			showMessage(params: params as! ShowMessageParams)
		case WINDOW_LOG_MESSAGE:
			logMessage(params: params as! LogMessageParams)
		case TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS:
			publishDiagnostics(params: params as! PublishDiagnosticsParams)
		default:
			fatalError()
		}
	}

}
