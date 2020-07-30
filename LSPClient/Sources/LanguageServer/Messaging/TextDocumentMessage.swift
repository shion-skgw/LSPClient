//
//  TextDocumentMessage.swift
//  LSPClient
//
//  Created by Shion on 2020/07/23.
//  Copyright © 2020 Shion. All rights reserved.
//

final class TextDocumentMessage {

	static let shared: TextDocumentMessage = TextDocumentMessage()
	private unowned var messageManager: MessageManager = MessageManager.shared

	private init() {}

	func didOpen(params: DidOpenTextDocumentParams) {
		let message = Message.notification(TEXT_DOCUMENT_DID_OPEN, params)
		messageManager.send(message: message)
	}

	func didChange(params: DidChangeTextDocumentParams) {
		let message = Message.notification(TEXT_DOCUMENT_DID_CHANGE, params)
		messageManager.send(message: message)
	}

	func didSave(params: DidSaveTextDocumentParams) {
		let message = Message.notification(TEXT_DOCUMENT_DID_SAVE, params)
		messageManager.send(message: message)
	}

	func didClose(params: DidCloseTextDocumentParams) {
		let message = Message.notification(TEXT_DOCUMENT_DID_CLOSE, params)
		messageManager.send(message: message)
	}

	func completion(params: CompletionParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_COMPLETION, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func completionResolve(params: CompletionItem, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: COMPLETION_ITEM_RESOLVE, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func hover(params: HoverParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_HOVER, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

//	func declaration(params: DeclarationParams, source: TextDocumentResponceDelegate) -> RequestID {
//		let context = RequestContext(method: TEXT_DOCUMENT_DECLARATION, source: source)
//		let id = messageManager.nextId
//		let message = Message.request(id, context.method, params)
//		messageManager.send(message: message, context: context)
//		return id
//	}

	func definition(params: DefinitionParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_DEFINITION, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func typeDefinition(params: TypeDefinitionParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_TYPE_DEFINITION, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func implementation(params: ImplementationParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_IMPLEMENTATION, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func references(params: ReferenceParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_REFERENCES, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func documentHighlight(params: DocumentHighlightParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_DOCUMENT_HIGHLIGHT, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func documentSymbol(params: DocumentSymbolParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_DOCUMENT_SYMBOL, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func codeAction(params: CodeActionParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_CODE_ACTION, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

//	func formatting(params: DocumentFormattingParams, source: TextDocumentResponceDelegate) -> RequestID {
//		let context = RequestContext(method: TEXT_DOCUMENT_FORMATTING, source: source)
//		let id = messageManager.nextId
//		let message = Message.request(id, context.method, params)
//		messageManager.send(message: message, context: context)
//		return id
//	}

	func rangeFormatting(params: DocumentRangeFormattingParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_RANGE_FORMATTING, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

	func rename(params: RenameParams, source: TextDocumentResponceDelegate) -> RequestID {
		let context = RequestContext(method: TEXT_DOCUMENT_RENAME, source: source)
		let id = messageManager.nextId
		let message = Message.request(id, context.method, params)
		messageManager.send(message: message, context: context)
		return id
	}

}

protocol TextDocumentResponceDelegate: ResponceDelegate {

	func completion(id: RequestID, result: Result<CompletionList?, ErrorResponse>)
	func completionResolve(id: RequestID, result: Result<CompletionItem, ErrorResponse>)
	func hover(id: RequestID, result: Result<Hover?, ErrorResponse>)
//	func declaration(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
	func definition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
	func typeDefinition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
	func implementation(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>)
	func references(id: RequestID, result: Result<[Location]?, ErrorResponse>)
	func documentHighlight(id: RequestID, result: Result<[DocumentHighlight]?, ErrorResponse>)
	func documentSymbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>)
	func codeAction(id: RequestID, result: Result<CodeActionResult?, ErrorResponse>)
//	func formatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>)
	func rangeFormatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>)
	func rename(id: RequestID, result: Result<WorkspaceEdit?, ErrorResponse>)

}

extension TextDocumentResponceDelegate {

	func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool {
		guard let source = context.source as? TextDocumentResponceDelegate else {
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
//		case TEXT_DOCUMENT_DECLARATION:
//			source.declaration(id: id, result: or(result, error))
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
//		case TEXT_DOCUMENT_FORMATTING:
//			source.formatting(id: id, result: or(result, error))
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
