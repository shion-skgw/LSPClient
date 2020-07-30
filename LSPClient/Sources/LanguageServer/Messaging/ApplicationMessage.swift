//
//  ApplicationMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

final class ApplicationMessage {

	static let shared: ApplicationMessage = ApplicationMessage()
	private unowned var messageManager: MessageManager = MessageManager.shared

	private init() {}

	func cancelRequest(params: CancelParams) {
		let message = Message.notification(CANCEL_REQUEST, params)
		messageManager.send(message: message)
	}

	func initialize(params: InitializeParams, source: ApplicationResponceDelegate) -> RequestID {
		let context = RequestContext(method: INITIALIZE, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func initialized(params: InitializedParams) {
		let message = Message.notification(INITIALIZED, params)
		messageManager.send(message: message)
	}

	func shutdown(params: VoidValue, source: ApplicationResponceDelegate) -> RequestID {
		let context = RequestContext(method: SHUTDOWN, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func exit(params: VoidValue) {
		let message = Message.notification(EXIT, params)
		messageManager.send(message: message)
	}

}

protocol ApplicationResponceDelegate: ResponceDelegate {

	func initialize(id: RequestID, result: Result<InitializeResult, ErrorResponse>)
	func shutdown(id: RequestID, result: Result<VoidValue?, ErrorResponse>)

}

extension ApplicationResponceDelegate {

	func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
		guard let source = context.source as? ApplicationResponceDelegate else {
			fatalError()
		}

		switch context.method {
		case INITIALIZE:
			source.initialize(id: id, result: or(result, error))
		case SHUTDOWN:
			source.shutdown(id: id, result: or(result, error))
		default:
			throw MessageDecodingError.unsupportedMethod(id, context.method)
		}

		return true
	}

}
