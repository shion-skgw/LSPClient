//
//  TextDocumentMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

protocol TextDocumentMessageDelegate: MessageDelegate {

    func completion(id: RequestID, result: Result<CompletionList?, ErrorResponse>)
    func completionResolve(id: RequestID, result: Result<CompletionItem, ErrorResponse>)
    func hover(id: RequestID, result: Result<Hover?, ErrorResponse>)
//    func declaration(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
    func definition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
    func typeDefinition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
    func implementation(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
    func references(id: RequestID, result: Result<[Location]?, ErrorResponse>)
    func documentHighlight(id: RequestID, result: Result<[DocumentHighlight]?, ErrorResponse>)
    func documentSymbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>)
    func codeAction(id: RequestID, result: Result<CodeActionResult?, ErrorResponse>)
//    func formatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>)
    func rangeFormatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>)
    func rename(id: RequestID, result: Result<WorkspaceEdit?, ErrorResponse>)

}

extension TextDocumentMessageDelegate {

    func didOpen(params: DidOpenTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_OPEN, params)
        MessageManager.shared.send(message: message)
    }

    func didChange(params: DidChangeTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_CHANGE, params)
        MessageManager.shared.send(message: message)
    }

    func didSave(params: DidSaveTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_SAVE, params)
        MessageManager.shared.send(message: message)
    }

    func didClose(params: DidCloseTextDocumentParams) {
        let message = Message.notification(TEXT_DOCUMENT_DID_CLOSE, params)
        MessageManager.shared.send(message: message)
    }

    func completion(params: CompletionParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_COMPLETION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func completionResolve(params: CompletionItem) -> RequestID {
        let context = RequestContext(method: COMPLETION_ITEM_RESOLVE, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func hover(params: HoverParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_HOVER, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

//    func declaration(params: DeclarationParams) -> RequestID {
//        let context = RequestContext(method: TEXT_DOCUMENT_DECLARATION, source: self)
//        let id = MessageManager.shared.nextId
//        let message = Message.request(id, context.method, params)
//        MessageManager.shared.send(message: message, context: context)
//        return id
//    }

    func definition(params: DefinitionParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_DEFINITION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func typeDefinition(params: TypeDefinitionParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_TYPE_DEFINITION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func implementation(params: ImplementationParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_IMPLEMENTATION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func references(params: ReferenceParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_REFERENCES, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func documentHighlight(params: DocumentHighlightParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func documentSymbol(params: DocumentSymbolParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_DOCUMENT_SYMBOL, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func codeAction(params: CodeActionParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_CODE_ACTION, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

//    func formatting(params: DocumentFormattingParams) -> RequestID {
//        let context = RequestContext(method: TEXT_DOCUMENT_FORMATTING, source: self)
//        let id = MessageManager.shared.nextId
//        let message = Message.request(id, context.method, params)
//        MessageManager.shared.send(message: message, context: context)
//        return id
//    }

    func rangeFormatting(params: DocumentRangeFormattingParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_RANGE_FORMATTING, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func rename(params: RenameParams) -> RequestID {
        let context = RequestContext(method: TEXT_DOCUMENT_RENAME, source: self)
        let id = MessageManager.shared.nextId
        let message = Message.request(id, context.method, params)
        MessageManager.shared.send(message: message, context: context)
        return id
    }

    func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
        guard let source = context.source as? TextDocumentMessageDelegate else {
            fatalError()
        }

        switch context.method {
        case TEXT_DOCUMENT_COMPLETION:
            source.completion(id: id, result: or(result, error))
            if (result as? CompletionList)?.isIncomplete == true {
                return false
            }
        case COMPLETION_ITEM_RESOLVE:
            source.completionResolve(id: id, result: or(result, error))
        case TEXT_DOCUMENT_HOVER:
            source.hover(id: id, result: or(result, error))
//        case TEXT_DOCUMENT_DECLARATION:
//            source.declaration(id: id, result: or(result, error))
        case TEXT_DOCUMENT_DEFINITION:
            source.definition(id: id, result: or(result, error))
        case TEXT_DOCUMENT_TYPE_DEFINITION:
            source.typeDefinition(id: id, result: or(result, error))
        case TEXT_DOCUMENT_IMPLEMENTATION:
            source.implementation(id: id, result: or(result, error))
        case TEXT_DOCUMENT_REFERENCES:
            source.references(id: id, result: or(result, error))
        case TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT:
            source.documentHighlight(id: id, result: or(result, error))
        case TEXT_DOCUMENT_DOCUMENT_SYMBOL:
            source.documentSymbol(id: id, result: or(result, error))
        case TEXT_DOCUMENT_CODE_ACTION:
            source.codeAction(id: id, result: or(result, error))
//        case TEXT_DOCUMENT_FORMATTING:
//            source.formatting(id: id, result: or(result, error))
        case TEXT_DOCUMENT_RANGE_FORMATTING:
            source.rangeFormatting(id: id, result: or(result, error))
        case TEXT_DOCUMENT_RENAME:
            source.rename(id: id, result: or(result, error))
        default:
            throw MessageDecodingError.unsupportedMethod(id, context.method)
        }

        return true
    }

}
