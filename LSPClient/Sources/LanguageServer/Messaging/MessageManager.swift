//
//  MessageManager.swift
//  LSPClient
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

/// LSP request header format
private let REQUEST_HEADERS	= "Content-Length: %d\r\nContent-Type: application/vscode-jsonrpc; charset=utf8\r\n\r\n"
/// Open curly bracket "{"
private let OPEN_CURLY_BRACKET = UInt8(123)

typealias StoredRequest = (RequestID) -> String?

extension CodingUserInfoKey {
	static let storedRequest = CodingUserInfoKey(rawValue: "lsp.jsonrpc.storedRequest")!
}

struct RequestContext {
	let method: String
	weak var source: MessageDelegate?
}

///
/// LSP Message manager
///
final class MessageManager: LSPConnectionDelegate {

    /// MessageManager shared instance
    static let shared: MessageManager = MessageManager()
    /// MessageManager delegate
    weak var delegate: MessageManagerDelegate?
    /// Language server connection
    weak var connection: LSPConnection!
    /// JSON decoder
    private let decoder: JSONDecoder = JSONDecoder()
    /// JSON encoder
    private let encoder: JSONEncoder = JSONEncoder()
    /// Latest request ID
    private var lastRequestId: Int = 0
    /// Unprocessed request sent
    private var sendRequest: [RequestID: RequestContext] = Dictionary(minimumCapacity: 100)

    /// Next request ID
    var nextId: RequestID {
        lastRequestId += 1
        return .number(lastRequestId)
    }

    ///
    /// Initialize
    ///
    private init() {
        self.decoder.userInfo[.storedRequest] = {
            [unowned self] (id) -> String? in
            return self.sendRequest[id]?.method
        }
    }

    ///
    /// Connect to language server
    ///
    /// - Parameter server      : Language server
    ///
    func connection(server: LanguageServer) {
        connection.close()
        lastRequestId = 0
        sendRequest.removeAll()
        connection.connection(host: server.host, port: server.port)
    }

    ///
    /// Disconnect from language server
    ///
    func close() {
        connection.close()
    }

    ///
    /// Connection error handler
    ///
    /// - Parameter cause       : Error cause
    ///
    func connectionError(cause: Error) {
        delegate?.connectionError(cause: cause)
    }


    // MARK: - Receive request, notification, response

    ///
    /// Data receive handler
    ///
    /// - Parameter data        : Received data
    ///
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
            delegate?.messageParseError(cause: error, message: nil)
        }
    }

    ///
    /// Response receive handler
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    /// - Parameter error       : Error
    /// - Throws                : Received an unknown request ID
    ///
    private func receiveResponse(_ id: RequestID, _ result: ResultType?, _ error: ErrorResponse?) throws {
        guard let context = sendRequest[id] else {
            throw MessageDecodingError.unknownRequestID
        }
        if try context.source?.receiveResponse(id: id, context: context, result: result, error: error) ?? true {
            sendRequest.removeValue(forKey: id)
        }
    }

    ///
    /// Decode data
    ///
    /// - Parameter data        : Received data
    /// - Throws                : Decode failure
    /// - Returns               : Message
    ///
    private func decode(_ data: Data) throws -> Message {
        guard let firstIndex = data.firstIndex(of: OPEN_CURLY_BRACKET) else {
            throw DecodingError.dataCorruptedError([], "TODO")
        }
        return try decoder.decode(Message.self, from: data[firstIndex..<data.endIndex])
    }


    // MARK: - Send request, notification, response

    ///
    /// Send message
    ///
    /// - Parameter message     : Message
    /// - Parameter context     : Request context
    ///
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
            delegate?.messageParseError(cause: error, message: message)
        }
    }

    ///
    /// Encode data
    ///
    /// - Parameter message     : Message
    /// - Throws                : Encode failure
    /// - Returns               : Data
    ///
    private func encode(_ message: Message) throws -> Data {
        let message = try encoder.encode(message)
        var content = String(format: REQUEST_HEADERS, message.count).data(using: .utf8)!
        content.append(message)
        return content
    }


    // MARK: - for testing

    #if DEBUG
    var getSendRequest: [RequestID: RequestContext] {
        return sendRequest
    }
    func appendSendRequest(id: RequestID, method: String, source: MessageDelegate?) {
        sendRequest[id] = RequestContext(method: method, source: source)
    }
    #endif

}


// MARK: - Delegate

///
/// MessageManager delegate
///
protocol MessageManagerDelegate: class {

    func connectionError(cause: Error)
    func messageParseError(cause: Error, message: Message?)

    func cancelRequest(params: CancelParams)
    func showMessage(params: ShowMessageParams)
    func showMessageRequest(id: RequestID, params: ShowMessageRequestParams)
    func logMessage(params: LogMessageParams)
    func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams)
    func publishDiagnostics(params: PublishDiagnosticsParams)

}

extension MessageManagerDelegate {

    func showMessageRequest(id: RequestID, result: MessageActionItem?) {
        let message = Message.response(id, result)
        MessageManager.shared.send(message: message)
    }

    func applyEdit(id: RequestID, result: ApplyWorkspaceEditResponse) {
        let message = Message.response(id, result)
        MessageManager.shared.send(message: message)
    }

    func receiveRequest(id: RequestID, method: String, params: RequestParamsType) throws {
        switch method {
        case WINDOW_SHOW_MESSAGE_REQUEST:
            showMessageRequest(id: id, params: to(params))
        case WORKSPACE_APPLY_EDIT:
            applyEdit(id: id, params: to(params))
        default:
            throw MessageDecodingError.unsupportedMethod(id, method)
        }
    }

    func receiveNotification(method: String, params: NotificationParamsType) throws {
        switch method {
        case CANCEL_REQUEST:
            cancelRequest(params: to(params))
        case WINDOW_SHOW_MESSAGE:
            showMessage(params: to(params))
        case WINDOW_LOG_MESSAGE:
            logMessage(params: to(params))
        case TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS:
            publishDiagnostics(params: to(params))
        default:
            throw MessageDecodingError.unsupportedMethod(nil, method)
        }
    }

    private func to<T: ParamsType>(_ params: ParamsType) -> T {
        if let params = params as? T {
            return params
        } else {
            fatalError()
        }
    }

}

protocol MessageDelegate: class {

    func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool

}

extension MessageDelegate {

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
