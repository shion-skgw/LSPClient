//
//  WorkspaceMessageDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

protocol WorkspaceMessageDelegate: MessageDelegate {

    func symbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>)
    func executeCommand(id: RequestID, result: Result<AnyValue?, ErrorResponse>)

}

extension WorkspaceMessageDelegate {

    func didChangeConfiguration(params: DidChangeConfigurationParams) {
        let message = Message.notification(WORKSPACE_DID_CHANGE_CONFIGURATION, params)
        MessageManager.shared.send(message: message)
    }

    func didChangeWatchedFiles(params: DidChangeWatchedFilesParams) {
        let message = Message.notification(WORKSPACE_DID_CHANGE_WATCHED_FILES, params)
        MessageManager.shared.send(message: message)
    }

    func symbol(params: WorkspaceSymbolParams) -> RequestID {
        let context = RequestContext(method: WORKSPACE_SYMBOL, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func executeCommand(params: ExecuteCommandParams) -> RequestID {
        let context = RequestContext(method: WORKSPACE_EXECUTE_COMMAND, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func applyEdit(params: ApplyWorkspaceEditParams) -> RequestID {
        let context = RequestContext(method: WORKSPACE_APPLY_EDIT, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
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
