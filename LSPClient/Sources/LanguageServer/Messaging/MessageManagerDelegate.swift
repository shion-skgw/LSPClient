//
//  MessageManagerDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/09/14.
//  Copyright © 2020 Shion. All rights reserved.
//

///
/// MessageManager delegate
///
protocol MessageManagerDelegate: class {

    ///
    /// Language server connection error
    ///
    /// - Parameter cause: Error cause
    ///
    func connectionError(cause: Error)

    ///
    /// Message parsing error
    ///
    /// - Parameter cause  : Error cause
    /// - Parameter message: Message
    ///
    func messageParseError(cause: Error, message: Message?)

    ///
    /// Receive notification: $/cancelRequest
    ///
    /// - Parameter id    : Request ID
    /// - Parameter params: Parameter
    ///
    func cancelRequest(params: CancelParams)

    ///
    /// Receive notification: window/showMessage
    ///
    /// - Parameter id    : Request ID
    /// - Parameter params: Parameter
    ///
    func showMessage(params: ShowMessageParams)

    ///
    /// Receive request: window/showMessageRequest
    ///
    /// - Parameter id    : Request ID
    /// - Parameter params: Parameter
    ///
    func showMessageRequest(id: RequestID, params: ShowMessageRequestParams)

    ///
    /// Receive notification: window/logMessage
    ///
    /// - Parameter id    : Request ID
    /// - Parameter params: Parameter
    ///
    func logMessage(params: LogMessageParams)

    ///
    /// Receive request: workspace/applyEdit
    ///
    /// - Parameter id    : Request ID
    /// - Parameter params: Parameter
    ///
    func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams)

    ///
    /// Receive notification: textDocument/publishDiagnostics
    ///
    /// - Parameter id    : Request ID
    /// - Parameter params: Parameter
    ///
    func publishDiagnostics(params: PublishDiagnosticsParams)

}

extension MessageManagerDelegate {

    ///
    /// Send response: window/showMessageRequest
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func showMessageRequest(id: RequestID, result: MessageActionItem?) {
        let message = Message.response(id, result)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send response: workspace/applyEdit
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func applyEdit(id: RequestID, result: ApplyWorkspaceEditResponse) {
        let message = Message.response(id, result)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Request receive handler
    ///
    /// - Parameter id    : Request ID
    /// - Parameter method: Method
    /// - Parameter params: Parameter
    /// - Throws          : Unsupported methods
    ///
    func receiveRequest(id: RequestID, method: String, params: RequestParamsType) throws {
        switch method {
        case WINDOW_SHOW_MESSAGE_REQUEST:
            showMessageRequest(id: id, params: toParam(params))
        case WORKSPACE_APPLY_EDIT:
            applyEdit(id: id, params: toParam(params))
        default:
            throw MessageDecodingError.unsupportedMethod(id, method)
        }
    }

    ///
    /// Notification receive handler
    ///
    /// - Parameter method: Method
    /// - Parameter params: Parameter
    /// - Throws          : Unsupported methods
    ///
    func receiveNotification(method: String, params: NotificationParamsType) throws {
        switch method {
        case CANCEL_REQUEST:
            cancelRequest(params: toParam(params))
        case WINDOW_SHOW_MESSAGE:
            showMessage(params: toParam(params))
        case WINDOW_LOG_MESSAGE:
            logMessage(params: toParam(params))
        case TEXT_DOCUMENT_PUBLISH_DIAGNOSTICS:
            publishDiagnostics(params: toParam(params))
        default:
            throw MessageDecodingError.unsupportedMethod(nil, method)
        }
    }

    ///
    /// Type conversion of parameters
    ///
    /// - Parameter params: Parameter
    /// - Returns         : Converted parameter
    ///
    private func toParam<T: ParamsType>(_ params: ParamsType) -> T {
        if let params = params as? T {
            return params
        } else {
            fatalError()
        }
    }

}
