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


final class MessageManager: TCPConnectionDelegate {

	static let shared: MessageManager = MessageManager()

	weak var delegate: ServerMessageDelegate?

	private let decoder: JSONDecoder = JSONDecoder()

	private let encoder: JSONEncoder = JSONEncoder()

	private unowned var tcpConnection: TCPConnection = TCPConnection.shared

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

	func connection() {
		tcpConnection.close()
		currentId = 1
		sendRequest.removeAll()
		tcpConnection.connection(host: "", port: 123)
	}

	func close() {
		tcpConnection.close()
	}

	func connectionError(cause: Error) {
		delegate?.connectionError(cause: cause)
	}


	// MARK: - Receive request, notification, response

	func didReceive(data: Data) {
		do {
			let message = try decode(data)
			switch message {
			case .request(let id, let method, let params):
				delegate?.receiveRequest(id: id, method: method, params: params)

			case .notification(let method, let params):
				delegate?.receiveNotification(method: method, params: params)

			case .response(let id, let result, let error):
				guard let context = sendRequest[id] else {
					fatalError("TODO")
				}
				if context.source?.receiveResponse(id: id, context: context, result: result, error: error) ?? true {
					sendRequest.removeValue(forKey: id)
				}
			}
 
		} catch MessageDecodingError.unsupportedMethod(let id, let method) {
			print(method)
			if let id = id {
				let error = ErrorResponse(code: .methodNotFound, message: "", data: nil)
				sendErrorResponse(id: id, error: error)
			}

		} catch {
			// サーバーかクライアントのバグ or 未対応
			print(error)
			delegate?.codingError(cause: error, message: nil)
		}
	}

	private func decode(_ data: Data) throws -> Message {
		guard let firstIndex = data.firstIndex(of: OPEN_CURLY_BRACKET) else {
			throw DecodingError.dataCorruptedError([], "TODO")
		}
		return try decoder.decode(Message.self, from: data[firstIndex...data.endIndex])
	}


	// MARK: - Send request, notification, response

	func send(message: Message, context: RequestContext! = nil) {
		do {
			tcpConnection.send(data: try encode(message)) {
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
			delegate?.codingError(cause: error, message: message)
		}
	}

	func sendResponce(id: RequestID, result: ResultType) {
		send(message: .response(id, result, nil))
	}

	func sendErrorResponse(id: RequestID, error: ErrorResponse) {
		send(message: .response(id, nil, error))
	}

	private func encode(_ message: Message) throws -> Data {
		let message = try encoder.encode(message)
		let length = String(data: message, encoding: .utf8)!.utf8.count
		var content = String(format: REQUEST_HEADERS, length).data(using: .utf8)!
		content.append(message)
		return content
	}

}

extension MessageManager {

	struct RequestContext {
		let method: String
		weak var source: ResponceDelegate?
	}

}

// MARK: - Delegate

protocol ResponceDelegate: class {

	func receiveResponse(id: RequestID, context: MessageManager.RequestContext, result: ResultType?, error: ErrorResponse?) -> Bool

}

extension ResponceDelegate {

	func or<T: ResultType>(_ result: ResultType?, _ error: ErrorResponse?) -> Result<T, ErrorResponse> {
		if let error = error {
			return .failure(error)
		} else if let result = result as? T {
			return .success(result)
		} else {
			fatalError()
		}
	}

}
