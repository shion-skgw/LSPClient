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
    /// Receive result: workspace/symbol
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func symbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>)

    ///
    /// Receive result: workspace/executeCommand
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func executeCommand(id: RequestID, result: Result<AnyValue?, ErrorResponse>)

}

extension WorkspaceMessageDelegate {

    ///
    /// Send notification: workspace/didChangeConfiguration
    ///
    /// - Parameter params      : Parameter
    ///
    func didChangeConfiguration(params: DidChangeConfigurationParams) {
        let message = Message.notification(WORKSPACE_DID_CHANGE_CONFIGURATION, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: workspace/didChangeWatchedFiles
    ///
    /// - Parameter params      : Parameter
    ///
    func didChangeWatchedFiles(params: DidChangeWatchedFilesParams) {
        let message = Message.notification(WORKSPACE_DID_CHANGE_WATCHED_FILES, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: workspace/symbol
    ///
    /// - Parameter params      : Parameter
    ///
    func symbol(params: WorkspaceSymbolParams) -> RequestID {
        let context = MessageManager.RequestContext(method: WORKSPACE_SYMBOL, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: workspace/executeCommand
    ///
    /// - Parameter params      : Parameter
    ///
    func executeCommand(params: ExecuteCommandParams) -> RequestID {
        let context = MessageManager.RequestContext(method: WORKSPACE_EXECUTE_COMMAND, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: workspace/applyEdit
    ///
    /// - Parameter params      : Parameter
    ///
    func applyEdit(params: ApplyWorkspaceEditParams) -> RequestID {
        let context = MessageManager.RequestContext(method: WORKSPACE_APPLY_EDIT, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
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
        guard let source = context.source as? WorkspaceMessageDelegate else {
            fatalError()
        }

        switch context.method {
        case WORKSPACE_SYMBOL:
            source.symbol(id: id, result: toResult(result, error))
        case WORKSPACE_EXECUTE_COMMAND:
            source.executeCommand(id: id, result: toResult(result, error))
        default:
            throw MessageDecodingError.unsupportedMethod(id, context.method)
        }

        return true
    }

}
