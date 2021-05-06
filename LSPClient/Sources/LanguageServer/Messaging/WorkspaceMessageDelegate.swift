//
//  WorkspaceMessageDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

///
/// WorkspaceMessageDelegate
///
protocol WorkspaceMessageDelegate: MessageDelegate {

    ///
    /// Receive result: initialize
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func initialize(id: RequestID, result: InitializeResult)

    ///
    /// Receive result: shutdown
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func shutdown(id: RequestID, result: VoidValue?)

    ///
    /// Receive result: workspace/symbol
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func symbol(id: RequestID, result: [SymbolInformation]?)

    ///
    /// Receive result: workspace/executeCommand
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func executeCommand(id: RequestID, result: AnyValue?)

    ///
    /// Receive error
    ///
    /// - Parameter id    : Request ID
    /// - Parameter method: Method
    /// - Parameter error : Error
    ///
    func responseError(id: RequestID, method: MessageMethod, error: ErrorResponse)

}

extension WorkspaceMessageDelegate {

    ///
    /// Send notification: $/cancelRequest
    ///
    /// - Parameter params: Parameter
    ///
    func cancelRequest(params: CancelParams) {
        let message = Message.notification(.cancelRequest, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: initialize
    ///
    /// - Parameter params: Parameter
    ///
    func initialize(params: InitializeParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .initialize, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send notification: initialized
    ///
    /// - Parameter params: Parameter
    ///
    func initialized(params: InitializedParams) {
        let message = Message.notification(.initialized, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: shutdown
    ///
    /// - Parameter params: Parameter
    ///
    func shutdown(params: VoidValue) -> RequestID {
        let context = MessageManager.RequestContext(method: .shutdown, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send notification: exit
    ///
    /// - Parameter params: Parameter
    ///
    func exit(params: VoidValue) {
        let message = Message.notification(.exit, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: workspace/didChangeConfiguration
    ///
    /// - Parameter params: Parameter
    ///
    func didChangeConfiguration(params: DidChangeConfigurationParams) {
        let message = Message.notification(.workspaceDidChangeConfiguration, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: workspace/didChangeWatchedFiles
    ///
    /// - Parameter params: Parameter
    ///
    func didChangeWatchedFiles(params: DidChangeWatchedFilesParams) {
        let message = Message.notification(.workspaceDidChangeWatchedFiles, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: workspace/symbol
    ///
    /// - Parameter params: Parameter
    ///
    func symbol(params: WorkspaceSymbolParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .workspaceSymbol, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: workspace/executeCommand
    ///
    /// - Parameter params: Parameter
    ///
    func executeCommand(params: ExecuteCommandParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .workspaceExecuteCommand, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: workspace/applyEdit
    ///
    /// - Parameter params: Parameter
    ///
    func applyEdit(params: ApplyWorkspaceEditParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .workspaceApplyEdit, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Response receive handler
    ///
    /// - Parameter id     : Request ID
    /// - Parameter context: Request context
    /// - Parameter result : Result
    /// - Parameter error  : Error
    /// - Throws           : Unsupported methods
    /// - Returns          : Delete stored request
    ///
    func receiveResponse(id: RequestID, context: MessageManager.RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
        guard let source = context.source as? WorkspaceMessageDelegate else {
            fatalError()
        }

        if let error = error {
            source.responseError(id: id, method: context.method, error: error)
            return true
        }

        switch context.method {
        case .initialize:
            source.initialize(id: id, result: toResult(result))
        case .shutdown:
            source.shutdown(id: id, result: toResult(result))
        case .workspaceSymbol:
            source.symbol(id: id, result: toResult(result))
        case .workspaceExecuteCommand:
            source.executeCommand(id: id, result: toResult(result))
        default:
            throw MessageDecodingError.unsupportedMethod(id, context.method.rawValue)
        }

        return true
    }

}
