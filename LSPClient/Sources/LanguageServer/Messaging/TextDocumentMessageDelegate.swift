//
//  TextDocumentMessageDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

///
/// TextDocumentMessageDelegate
///
protocol TextDocumentMessageDelegate: MessageDelegate {

    ///
    /// Receive result: textDocument/completion
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func completion(id: RequestID, result: CompletionList?)

    ///
    /// Receive result: completionItem/resolve
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func completionResolve(id: RequestID, result: CompletionItem)

    ///
    /// Receive result: textDocument/hover
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func hover(id: RequestID, result: Hover?)

    ///
    /// Receive result: textDocument/signatureHelp
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func signatureHelp(id: RequestID, result: SignatureHelp?)

    ///
    /// Receive result: textDocument/declaration
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
//    func declaration(id: RequestID, result: FindLocationResult?)

    ///
    /// Receive result: textDocument/definition
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func definition(id: RequestID, result: FindLocationResult?)

    ///
    /// Receive result: textDocument/typeDefinition
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func typeDefinition(id: RequestID, result: FindLocationResult?)

    ///
    /// Receive result: textDocument/implementation
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func implementation(id: RequestID, result: FindLocationResult?)

    ///
    /// Receive result: textDocument/references
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func references(id: RequestID, result: [Location]?)

    ///
    /// Receive result: textDocument/documentHighlight
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func documentHighlight(id: RequestID, result: [DocumentHighlight]?)

    ///
    /// Receive result: textDocument/documentSymbol
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func documentSymbol(id: RequestID, result: [SymbolInformation]?)

    ///
    /// Receive result: textDocument/codeAction
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func codeAction(id: RequestID, result: CodeActionResult?)

    ///
    /// Receive result: textDocument/formatting
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
//    func formatting(id: RequestID, result: [TextEdit]?)

    ///
    /// Receive result: textDocument/rangeFormatting
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func rangeFormatting(id: RequestID, result: [TextEdit]?)

    ///
    /// Receive result: textDocument/rename
    ///
    /// - Parameter id    : Request ID
    /// - Parameter result: Result
    ///
    func rename(id: RequestID, result: WorkspaceEdit?)

    ///
    /// Receive error
    ///
    /// - Parameter id    : Request ID
    /// - Parameter method: Method
    /// - Parameter error : Error
    ///
    func responseError(id: RequestID, method: MessageMethod, error: ErrorResponse)

}

extension TextDocumentMessageDelegate {

    ///
    /// Send notification: textDocument/didOpen
    ///
    /// - Parameter params: Parameter
    ///
    func didOpen(params: DidOpenTextDocumentParams) {
        let message = Message.notification(.textDocumentDidOpen, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: textDocument/didChange
    ///
    /// - Parameter params: Parameter
    ///
    func didChange(params: DidChangeTextDocumentParams) {
        let message = Message.notification(.textDocumentDidChange, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: textDocument/didSave
    ///
    /// - Parameter params: Parameter
    ///
    func didSave(params: DidSaveTextDocumentParams) {
        let message = Message.notification(.textDocumentDidSave, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: textDocument/didClose
    ///
    /// - Parameter params: Parameter
    ///
    func didClose(params: DidCloseTextDocumentParams) {
        let message = Message.notification(.textDocumentDidClose, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: textDocument/completion
    ///
    /// - Parameter params: Parameter
    ///
    func completion(params: CompletionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentCompletion, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: completionItem/resolve
    ///
    /// - Parameter params: Parameter
    ///
    func completionResolve(params: CompletionItem) -> RequestID {
        let context = MessageManager.RequestContext(method: .completionItemResolve, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/hover
    ///
    /// - Parameter params: Parameter
    ///
    func hover(params: HoverParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentHover, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/signatureHelp
    ///
    /// - Parameter params: Parameter
    ///
    func signatureHelp(params: SignatureHelpParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentSignatureHelp, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/declaration
    ///
    /// - Parameter params: Parameter
    ///
//    func declaration(params: DeclarationParams) -> RequestID {
//        let context = MessageManager.RequestContext(method: .textDocumentDeclaration, source: self)
//        let id = MessageManager.shared.nextId
//        let message = Message.request(id, context.method, params)
//        MessageManager.shared.send(message: message, context: context)
//        return id
//    }

    ///
    /// Send request: textDocument/definition
    ///
    /// - Parameter params: Parameter
    ///
    func definition(params: DefinitionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentDefinition, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/typeDefinition
    ///
    /// - Parameter params: Parameter
    ///
    func typeDefinition(params: TypeDefinitionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentTypeDefinition, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/implementation
    ///
    /// - Parameter params: Parameter
    ///
    func implementation(params: ImplementationParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentImplementation, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/references
    ///
    /// - Parameter params: Parameter
    ///
    func references(params: ReferenceParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentReferences, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/documentHighlight
    ///
    /// - Parameter params: Parameter
    ///
    func documentHighlight(params: DocumentHighlightParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentDocumentHighlight, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/documentSymbol
    ///
    /// - Parameter params: Parameter
    ///
    func documentSymbol(params: DocumentSymbolParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentDocumentSymbol, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/codeAction
    ///
    /// - Parameter params: Parameter
    ///
    func codeAction(params: CodeActionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentCodeAction, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/formatting
    ///
    /// - Parameter params: Parameter
    ///
//    func formatting(params: DocumentFormattingParams) -> RequestID {
//        let context = MessageManager.RequestContext(method: .textDocumentFormatting, source: self)
//        let id = MessageManager.shared.nextId
//        let message = Message.request(id, context.method, params)
//        MessageManager.shared.send(message: message, context: context)
//        return id
//    }

    ///
    /// Send request: textDocument/rangeFormatting
    ///
    /// - Parameter params: Parameter
    ///
    func rangeFormatting(params: DocumentRangeFormattingParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentRangeFormatting, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/rename
    ///
    /// - Parameter params: Parameter
    ///
    func rename(params: RenameParams) -> RequestID {
        let context = MessageManager.RequestContext(method: .textDocumentRename, source: self)
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
        guard let source = context.source as? TextDocumentMessageDelegate else {
            fatalError()
        }

        if let error = error {
            source.responseError(id: id, method: context.method, error: error)
            return true
        }

        switch context.method {
        case .textDocumentCompletion:
            source.completion(id: id, result: toResult(result))
            return (result as? CompletionList)?.isIncomplete == false
        case .completionItemResolve:
            source.completionResolve(id: id, result: toResult(result))
        case .textDocumentHover:
            source.hover(id: id, result: toResult(result))
        case .textDocumentSignatureHelp:
            source.signatureHelp(id: id, result: toResult(result))
//        case .textDocumentDeclaration:
//            source.declaration(id: id, result: toResult(result)
        case .textDocumentDefinition:
            source.definition(id: id, result: toResult(result))
        case .textDocumentTypeDefinition:
            source.typeDefinition(id: id, result: toResult(result))
        case .textDocumentImplementation:
            source.implementation(id: id, result: toResult(result))
        case .textDocumentReferences:
            source.references(id: id, result: toResult(result))
        case .textDocumentDocumentHighlight:
            source.documentHighlight(id: id, result: toResult(result))
        case .textDocumentDocumentSymbol:
            source.documentSymbol(id: id, result: toResult(result))
        case .textDocumentCodeAction:
            source.codeAction(id: id, result: toResult(result))
//        case .textDocumentFormatting:
//            source.formatting(id: id, result: toResult(result)
        case .textDocumentRangeFormatting:
            source.rangeFormatting(id: id, result: toResult(result))
        case .textDocumentRename:
            source.rename(id: id, result: toResult(result))
        default:
            throw MessageDecodingError.unsupportedMethod(id, context.method.rawValue)
        }

        return true
    }

}
