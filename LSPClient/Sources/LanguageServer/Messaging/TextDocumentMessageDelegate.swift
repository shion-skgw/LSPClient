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
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func completion(id: RequestID, result: Result<CompletionList?, ErrorResponse>)

    ///
    /// Receive result: completionItem/resolve
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func completionResolve(id: RequestID, result: Result<CompletionItem, ErrorResponse>)

    ///
    /// Receive result: textDocument/hover
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func hover(id: RequestID, result: Result<Hover?, ErrorResponse>)

    ///
    /// Receive result: textDocument/declaration
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
//    func declaration(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)

    ///
    /// Receive result: textDocument/definition
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func definition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)

    ///
    /// Receive result: textDocument/typeDefinition
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func typeDefinition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)

    ///
    /// Receive result: textDocument/implementation
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func implementation(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)

    ///
    /// Receive result: textDocument/references
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func references(id: RequestID, result: Result<[Location]?, ErrorResponse>)

    ///
    /// Receive result: textDocument/documentHighlight
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func documentHighlight(id: RequestID, result: Result<[DocumentHighlight]?, ErrorResponse>)

    ///
    /// Receive result: textDocument/documentSymbol
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func documentSymbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>)

    ///
    /// Receive result: textDocument/codeAction
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func codeAction(id: RequestID, result: Result<CodeActionResult?, ErrorResponse>)

    ///
    /// Receive result: textDocument/formatting
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
//    func formatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>)

    ///
    /// Receive result: textDocument/rangeFormatting
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func rangeFormatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>)

    ///
    /// Receive result: textDocument/rename
    ///
    /// - Parameter id          : Request ID
    /// - Parameter result      : Result
    ///
    func rename(id: RequestID, result: Result<WorkspaceEdit?, ErrorResponse>)

}

extension TextDocumentMessageDelegate {

    ///
    /// Send notification: textDocument/didOpen
    ///
    /// - Parameter params      : Parameter
    ///
    func didOpen(params: DidOpenTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_OPEN, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: textDocument/didChange
    ///
    /// - Parameter params      : Parameter
    ///
    func didChange(params: DidChangeTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_CHANGE, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: textDocument/didSave
    ///
    /// - Parameter params      : Parameter
    ///
    func didSave(params: DidSaveTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_SAVE, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send notification: textDocument/didClose
    ///
    /// - Parameter params      : Parameter
    ///
    func didClose(params: DidCloseTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_CLOSE, params)
        MessageManager.shared.send(message: message)
    }

    ///
    /// Send request: textDocument/completion
    ///
    /// - Parameter params      : Parameter
    ///
    func completion(params: CompletionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_COMPLETION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: completionItem/resolve
    ///
    /// - Parameter params      : Parameter
    ///
    func completionResolve(params: CompletionItem) -> RequestID {
        let context = MessageManager.RequestContext(method: COMPLETION_ITEM_RESOLVE, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/hover
    ///
    /// - Parameter params      : Parameter
    ///
    func hover(params: HoverParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_HOVER, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/declaration
    ///
    /// - Parameter params      : Parameter
    ///
//    func declaration(params: DeclarationParams) -> RequestID {
//        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_DECLARATION, source: self)
//        let id = MessageManager.shared.nextId
//        let message = Message.request(id, context.method, params)
//        MessageManager.shared.send(message: message, context: context)
//        return id
//    }

    ///
    /// Send request: textDocument/definition
    ///
    /// - Parameter params      : Parameter
    ///
    func definition(params: DefinitionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_DEFINITION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/typeDefinition
    ///
    /// - Parameter params      : Parameter
    ///
    func typeDefinition(params: TypeDefinitionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_TYPE_DEFINITION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/implementation
    ///
    /// - Parameter params      : Parameter
    ///
    func implementation(params: ImplementationParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_IMPLEMENTATION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/references
    ///
    /// - Parameter params      : Parameter
    ///
    func references(params: ReferenceParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_REFERENCES, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/documentHighlight
    ///
    /// - Parameter params      : Parameter
    ///
    func documentHighlight(params: DocumentHighlightParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/documentSymbol
    ///
    /// - Parameter params      : Parameter
    ///
    func documentSymbol(params: DocumentSymbolParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_DOCUMENT_SYMBOL, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/codeAction
    ///
    /// - Parameter params      : Parameter
    ///
    func codeAction(params: CodeActionParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_CODE_ACTION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/formatting
    ///
    /// - Parameter params      : Parameter
    ///
//    func formatting(params: DocumentFormattingParams) -> RequestID {
//        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_FORMATTING, source: self)
//        let id = MessageManager.shared.nextId
//        let message = Message.request(id, context.method, params)
//        MessageManager.shared.send(message: message, context: context)
//        return id
//    }

    ///
    /// Send request: textDocument/rangeFormatting
    ///
    /// - Parameter params      : Parameter
    ///
    func rangeFormatting(params: DocumentRangeFormattingParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_RANGE_FORMATTING, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    ///
    /// Send request: textDocument/rename
    ///
    /// - Parameter params      : Parameter
    ///
    func rename(params: RenameParams) -> RequestID {
        let context = MessageManager.RequestContext(method: TEXT_DOCUMENT_RENAME, source: self)
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
        guard let source = context.source as? TextDocumentMessageDelegate else {
            fatalError()
        }

        switch context.method {
        case TEXT_DOCUMENT_COMPLETION:
            source.completion(id: id, result: toResult(result, error))
            return (result as? CompletionList)?.isIncomplete == false
        case COMPLETION_ITEM_RESOLVE:
            source.completionResolve(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_HOVER:
            source.hover(id: id, result: toResult(result, error))
//        case TEXT_DOCUMENT_DECLARATION:
//            source.declaration(id: id, result: or(result, error))
        case TEXT_DOCUMENT_DEFINITION:
            source.definition(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_TYPE_DEFINITION:
            source.typeDefinition(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_IMPLEMENTATION:
            source.implementation(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_REFERENCES:
            source.references(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT:
            source.documentHighlight(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_DOCUMENT_SYMBOL:
            source.documentSymbol(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_CODE_ACTION:
            source.codeAction(id: id, result: toResult(result, error))
//        case TEXT_DOCUMENT_FORMATTING:
//            source.formatting(id: id, result: or(result, error))
        case TEXT_DOCUMENT_RANGE_FORMATTING:
            source.rangeFormatting(id: id, result: toResult(result, error))
        case TEXT_DOCUMENT_RENAME:
            source.rename(id: id, result: toResult(result, error))
        default:
            throw MessageDecodingError.unsupportedMethod(id, context.method)
        }

        return true
    }

}
