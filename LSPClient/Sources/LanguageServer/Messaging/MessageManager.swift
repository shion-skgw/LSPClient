//
//  MessageManager.swift
//  LSPClient
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

private let REQUEST_HEADERS	= "Content-Length: %d\r\nContent-Type: application/vscode-jsonrpc; charset=utf8\r\n\r\n"
private let OPEN_CURLY_BRACKET = UInt8(123)

typealias StoredRequest = (RequestID) -> String?

extension CodingUserInfoKey {
	static let storedRequest = CodingUserInfoKey(rawValue: "lsp.jsonrpc.storedRequest")!
}

struct RequestContext {
	let method: String
	weak var source: ResponceDelegate?
}


final class MessageManager: LSPConnectionDelegate {

	static let shared: MessageManager = MessageManager()

	weak var delegate: MessageManagerDelegate?

	weak var connection: LSPConnection!

	private let decoder: JSONDecoder = JSONDecoder()

	private let encoder: JSONEncoder = JSONEncoder()

	private var sendRequest: [RequestID: RequestContext] = Dictionary(minimumCapacity: 100)

	private var currentId: Int = 1

	var nextId: RequestID {
		currentId += 1
		return .number(currentId)
	}

	private init() {
		self.decoder.userInfo[.storedRequest] = {
			[unowned self] (id) -> String? in
			return self.sendRequest[id]?.method
		}
	}

	func connection(a: Int) {
		connection.close()
		currentId = 1
		sendRequest.removeAll()
		connection.connection(host: "", port: 123)
	}

	func close() {
		connection.close()
	}

	func connectionError(cause: Error) {
		delegate?.connectionError(cause: cause)
	}

	#if DEBUG
	func appendSendRequest(id: RequestID, method: String, source: ResponceDelegate?) {
		sendRequest[id] = RequestContext(method: method, source: source)
	}
	#endif


	// MARK: - Receive request, notification, response

	func didReceive(data: Data) {
		do {
			let message = try decode(data)
			switch message {
			case .request(let id, let method, let params):
				try delegate?.receiveRequest(id: id, method: method, params: params)

			case .notification(let method, let params):
				try delegate?.receiveNotification(method: method, params: params)

			case .response(let id, let result):
				try receiveResponse(id, result, nil)

			case .errorResponse(let id, let error):
				try receiveResponse(id, nil, error)
			}
 
		} catch {
			print(error)
			delegate?.messageError(cause: error, message: nil)
		}
	}

	private func receiveResponse(_ id: RequestID, _ result: ResultType?, _ error: ErrorResponse?) throws {
		guard let context = sendRequest[id] else {
			throw MessageDecodingError.unknownRequestID
		}
		if try context.source?.receiveResponse(id: id, context: context, result: result, error: error) ?? true {
			sendRequest.removeValue(forKey: id)
		}
	}

	private func decode(_ data: Data) throws -> Message {
		guard let firstIndex = data.firstIndex(of: OPEN_CURLY_BRACKET) else {
			throw DecodingError.dataCorruptedError([], "TODO")
		}
		return try decoder.decode(Message.self, from: data[firstIndex..<data.endIndex])
	}


	// MARK: - Send request, notification, response

	func send(message: Message, context: RequestContext! = nil) {
		do {
			connection.send(data: try encode(message)) {
				[unowned self, message] in
				switch message {
				case .request(let id, _, _):
					self.sendRequest[id] = context
				default:
					break
				}
			}
		} catch {
			// 発生しないはず
			delegate?.messageError(cause: error, message: message)
		}
	}

	private func encode(_ message: Message) throws -> Data {
		let message = try encoder.encode(message)
		var content = String(format: REQUEST_HEADERS, message.count).data(using: .utf8)!
		content.append(message)
		return content
	}

}


// MARK: - Delegate

protocol MessageManagerDelegate: class {

	func messageError(cause: Error, message: Message?)
	func connectionError(cause: Error)

	func cancelRequest(params: CancelParams)
	func showMessage(params: ShowMessageParams)
	func showMessageRequest(id: RequestID, params: ShowMessageRequestParams)
	func logMessage(params: LogMessageParams)
	func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams)
	func publishDiagnostics(params: PublishDiagnosticsParams)

}

extension MessageManagerDelegate {

	func receiveRequest(id: RequestID, method: String, params: RequestParamsType) throws {
		switch method {
		case WINDOW_SHOW_MESSAGE_REQUEST:
			showMessageRequest(id: id, params: params as! ShowMessageRequestParams)
		case WORKSPACE_APPLY_EDIT:
			applyEdit(id: id, params: params as! ApplyWorkspaceEditParams)
		default:
			throw MessageDecodingError.unsupportedMethod(id, method)
		}
	}

	func receiveNotification(method: String, params: NotificationParamsType) throws {
		switch method {
		case CANCEL_REQUEST:
			cancelRequest(params: params as! CancelParams)
		case WINDOW_SHOW_MESSAGE:
			showMessage(params: params as! ShowMessageParams)
		case WINDOW_LOG_MESSAGE:
			logMessage(params: params as! LogMessageParams)
		case TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS:
			publishDiagnostics(params: params as! PublishDiagnosticsParams)
		default:
			throw MessageDecodingError.unsupportedMethod(nil, method)
		}
	}

}

protocol ResponceDelegate: class {

	func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool

}

extension ResponceDelegate {

	func or<T: ResultType>(_ result: ResultType?, _ error: ErrorResponse?) -> Result<T, ErrorResponse> {
		if let result = result as? T {
			return .success(result)
		} else if let error = error {
			return .failure(error)
		} else {
			fatalError()
		}
	}

}
