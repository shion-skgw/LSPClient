//
//  ServerMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

final class ServerMessage {

	static let shared: ServerMessage = ServerMessage()
	private unowned var messageManager: MessageManager = MessageManager.shared

	private init() {}

	func showMessageRequest(id: RequestID, result: MessageActionItem?) {
		let message = Message.response(id, result)
		messageManager.send(message: message)
	}

	func applyEdit(id: RequestID, result: ApplyWorkspaceEditResponse) {
		let message = Message.response(id, result)
		messageManager.send(message: message)
	}

}
