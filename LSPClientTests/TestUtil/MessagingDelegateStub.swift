//
//  MessagingDelegateStub.swift
//  LSPClientTests
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation
@testable import LSPClient

class MessageManagerDelegateStub: MessageManagerDelegate {
	var function: String!
	var params: ParamsType!
	var id: RequestID!
	var cause: Error!
	var message: Message!

	func messageError(cause: Error, message: Message?) {
		self.function = #function
		self.cause = cause
		self.message = message
	}

	func connectionError(cause: Error) {
		self.function = #function
		self.cause = cause
	}

	func cancelRequest(params: CancelParams) {
		self.function = #function
		self.params = params
	}
	
	func showMessage(params: ShowMessageParams) {
		self.function = #function
		self.params = params
	}

	func showMessageRequest(id: RequestID, params: ShowMessageRequestParams) {
		self.function = #function
		self.params = params
		self.id = id
	}

	func logMessage(params: LogMessageParams) {
		self.function = #function
		self.params = params
	}

	func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams) {
		self.function = #function
		self.params = params
		self.id = id
	}

	func publishDiagnostics(params: PublishDiagnosticsParams) {
		self.function = #function
		self.params = params
	}

}

class ApplicationResponceDelegateStub: ApplicationResponceDelegate {
	var function: String!
	var result: ResultType!
	var error: ErrorResponse!
	var id: RequestID!

	func initialize(id: RequestID, result: Result<InitializeResult, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func shutdown(id: RequestID, result: Result<VoidValue?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

}

class WorkspaceResponceDelegateStub: WorkspaceResponceDelegate {
	var function: String!
	var result: ResultType!
	var error: ErrorResponse!
	var id: RequestID!

	func symbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func executeCommand(id: RequestID, result: Result<AnyValue?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

}

class TextDocumentResponceDelegateStub: TextDocumentResponceDelegate {
	var function: String!
	var result: ResultType!
	var error: ErrorResponse!
	var id: RequestID!

	func completion(id: RequestID, result: Result<CompletionList?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func completionResolve(id: RequestID, result: Result<CompletionItem, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func hover(id: RequestID, result: Result<Hover?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func definition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func typeDefinition(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func implementation(id: RequestID, result: Result<FindLocationResult?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func references(id: RequestID, result: Result<[Location]?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func documentHighlight(id: RequestID, result: Result<[DocumentHighlight]?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func documentSymbol(id: RequestID, result: Result<[SymbolInformation]?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func codeAction(id: RequestID, result: Result<CodeActionResult?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func rangeFormatting(id: RequestID, result: Result<[TextEdit]?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

	func rename(id: RequestID, result: Result<WorkspaceEdit?, ErrorResponse>) {
		self.function = #function
		switch result {
		case .success(let result): self.result = result
		case .failure(let error):  self.error  = error
		}
		self.id = id
	}

}
