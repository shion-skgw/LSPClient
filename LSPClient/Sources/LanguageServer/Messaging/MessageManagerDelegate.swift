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
            showMessageRequest(id: id, params: toParam(params))
        case WORKSPACE_APPLY_EDIT:
            applyEdit(id: id, params: toParam(params))
        default:
            throw MessageDecodingError.unsupportedMethod(id, method)
        }
    }

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

    private func toParam<T: ParamsType>(_ params: ParamsType) -> T {
        if let params = params as? T {
            return params
        } else {
            fatalError()
        }
    }

}

