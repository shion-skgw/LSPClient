//
//  ApplicationMessageDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

///
/// ApplicationMessageDelegate
///
protocol ApplicationMessageDelegate: MessageDelegate {

    ///
    /// Receive result: initialize
    /// 
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func initialize(id: RequestID, result: Result<InitializeResult, ErrorResponse>)

    ///
    /// Receive result: shutdown
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func shutdown(id: RequestID, result: Result<VoidValue?, ErrorResponse>)

}

extension ApplicationMessageDelegate {

    ///
    /// Send notification: $/cancelRequest
    ///
    /// - Parameter params      : Parameter
    ///
    func cancelRequest(params: CancelParams) {
        let message = Message.notification(CANCEL_REQUEST, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: initialize
    ///
    /// - Parameter params      : Parameter
    ///
    func initialize(params: InitializeParams) -> RequestID {
        let context = MessageManager.RequestContext(method: INITIALIZE, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send notification: initialized
    ///
    /// - Parameter params      : Parameter
    ///
    func initialized(params: InitializedParams) {
        let message = Message.notification(INITIALIZED, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: shutdown
    ///
    /// - Parameter params      : Parameter
    ///
    func shutdown(params: VoidValue) -> RequestID {
        let context = MessageManager.RequestContext(method: SHUTDOWN, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send notification: exit
    ///
    /// - Parameter params      : Parameter
    ///
    func exit(params: VoidValue) {
        let message = Message.notification(EXIT, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Response receive handler
    ///
    /// - Parameter id          : Request ID
    /// - Parameter context     : Request context
    /// - Parameter result      : Result
    /// - Parameter error       : Error
    /// - Throws                : Unsupported methods
    /// - Returns               : Delete stored request
    ///
    func receiveResponse(id: RequestID, context: MessageManager.RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
        guard let source = context.source as? ApplicationMessageDelegate else {
            fatalError()
        }

        switch context.method {
        case INITIALIZE:
            source.initialize(id: id, result: toResult(result, error))
        case SHUTDOWN:
            source.shutdown(id: id, result: toResult(result, error))
        default:
            throw MessageDecodingError.unsupportedMethod(id, context.method)
        }

        return true
    }

}
