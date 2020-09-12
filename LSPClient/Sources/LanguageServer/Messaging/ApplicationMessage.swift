//
//  ApplicationMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

protocol ApplicationMessageDelegate: MessageDelegate {

    func initialize(id: RequestID, result: Result<InitializeResult, ErrorResponse>)
    func shutdown(id: RequestID, result: Result<VoidValue?, ErrorResponse>)

}

extension ApplicationMessageDelegate {

    func cancelRequest(params: CancelParams) {
        let message = Message.notification(CANCEL_REQUEST, params)
        MessageManager.shared.send(message: message)
    }

    func initialize(params: InitializeParams) -> RequestID {
        let context = RequestContext(method: INITIALIZE, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func initialized(params: InitializedParams) {
        let message = Message.notification(INITIALIZED, params)
        MessageManager.shared.send(message: message)
    }

    func shutdown(params: VoidValue) -> RequestID {
        let context = RequestContext(method: SHUTDOWN, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func exit(params: VoidValue) {
        let message = Message.notification(EXIT, params)
        MessageManager.shared.send(message: message)
    }

    func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
        guard let source = context.source as? ApplicationMessageDelegate else {
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
