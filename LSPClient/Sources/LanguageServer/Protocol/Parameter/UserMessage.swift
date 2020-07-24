//
//  UserMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - ShowMessage Notification (window/showMessage)

struct ShowMessageParams: NotificationParamsType {
	let type: MessageType
	let message: String
}

enum MessageType: Int, Codable {
	case error = 1
	case warning = 2
	case info = 3
	case log = 4
}


// MARK: - ShowMessage Request (window/showMessageRequest)

struct ShowMessageRequestParams: RequestParamsType {
	let type: MessageType
	let message: String
	let actions: [MessageActionItem]?
}

struct MessageActionItem: Codable {
	let title: String
}


// MARK: - LogMessage Notification (window/logMessage)

struct LogMessageParams: NotificationParamsType {
	let type: MessageType
	let message: String
}
