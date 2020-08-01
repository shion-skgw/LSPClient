//
//  LSPMessagingTests.swift
//  LSPClientTests
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import XCTest
@testable import LSPClient

class LSPMessagingTests: XCTestCase {

	var manager: MessageManagerDelegateStub!
	var application: ApplicationMessageDelegateStub!
	var workspace: WorkspaceMessageDelegateStub!
	var textDocument: TextDocumentMessageDelegateStub!

	override func setUp() {
		self.manager = MessageManagerDelegateStub()
		self.application = ApplicationMessageDelegateStub()
		self.workspace = WorkspaceMessageDelegateStub()
		self.textDocument = TextDocumentMessageDelegateStub()
		MessageManager.shared.delegate = self.manager
		MessageManager.shared.connection = TestConnection.shared
		MessageManager.shared.connection(a: 0)
		TestConnection.shared.delegate = MessageManager.shared
	}


	// MARK: - Coding error

	func test_invalidJson_01() {
		// Execute
		let json = #"{jsonrpc = 2.0}"#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case DecodingError.dataCorrupted(_):
			break
		default:
			XCTFail()
		}
	}

	func test_invalidJson_02() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "1.0",
			"method": "window/showMessage",
			"params": {
				"type": 1,
				"message": "MESSAGE"
			}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case DecodingError.dataCorrupted(let context):
			XCTAssertEqual(context.codingPath.last?.stringValue, "jsonrpc")
		default:
			XCTFail()
		}
	}

	func test_invalidJson_03() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"method": "window/showMessage"
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case DecodingError.valueNotFound(_, _):
			break
		default:
			XCTFail()
		}
	}

	func test_invalidJson_04() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0,
			"id": 1,
			"method": "method",
			"params": {},
			"result": {},
			"error": {}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case DecodingError.dataCorrupted(_):
			break
		default:
			XCTFail()
		}
	}

	func test_invalidMessage_01() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"id": 1,
			"method": "method",
			"params": {}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case MessageDecodingError.unsupportedMethod(_, _):
			break
		default:
			XCTFail()
		}
	}

	func test_invalidMessage_02() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"method": "method",
			"params": {}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case MessageDecodingError.unsupportedMethod(_, _):
			break
		default:
			XCTFail()
		}
	}

	func test_invalidMessage_03() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"id": "ID",
			"result": {}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case MessageDecodingError.unknownRequestID:
			break
		default:
			XCTFail()
		}
	}

	func test_invalidMessage_04() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"id": "ID",
			"error": {}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case MessageDecodingError.unknownRequestID:
			break
		default:
			XCTFail()
		}
	}

	func test_invalidMessage_05() {
		// Execute
		MessageManager.shared.appendSendRequest(id: .string("ID"), method: "method", source: nil)
		let json = #"""
		{
			"jsonrpc": "2.0",
			"id": "ID",
			"result": {}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertEqual(MessageManager.shared.getSendRequest.count, 1)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "messageError(cause:message:)")
		XCTAssertNotNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert Error
		guard let cause = manager.cause else { XCTFail(); return }
		switch cause {
		case MessageDecodingError.unsupportedMethod(_, _):
			break
		default:
			XCTFail()
		}
	}


	// MARK: - From server message

	func test_window_showMessage_01() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"method": "window/showMessage",
			"params": {
				"type": 1,
				"message": "MESSAGE"
			}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "showMessage(params:)")
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNotNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert ShowMessageParams
		guard let params = manager.params as? ShowMessageParams else { XCTFail(); return }
		XCTAssertEqual(params.type, .error)
		XCTAssertEqual(params.message, "MESSAGE")
	}

	func test_window_showMessageRequest_01() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"id": "ID",
			"method": "window/showMessageRequest",
			"params": {
				"type": 1,
				"message": "MESSAGE",
				"actions": [
					{ "title": "TITLE0" }
				]
			}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "showMessageRequest(id:params:)")
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNotNil(manager.params)
		XCTAssertEqual(manager.id, .string("ID"))

		// Assert ShowMessageRequestParams
		guard let params = manager.params as? ShowMessageRequestParams else { XCTFail(); return }
		XCTAssertEqual(params.type, .error)
		XCTAssertEqual(params.message, "MESSAGE")
		XCTAssertEqual(params.actions?.count, 1)
		XCTAssertEqual(params.actions?[0].title, "TITLE0")
	}

	func test_window_showMessageRequest_02() {
		// Execute
		manager.showMessageRequest(id: .string("ID"), result: nil)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["id"], "ID")
		XCTAssertEqual(content["result"]?.isNull, true)
	}

	func test_window_showMessageRequest_03() {
		// Execute
		let result = MessageActionItem(title: "TITLE")
		manager.showMessageRequest(id: .string("ID"), result: result)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["id"], "ID")
		XCTAssertEqual(content["result"]?["title"], "TITLE")
	}

	func test_window_logMessage_01() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"method": "window/logMessage",
			"params": {
				"type": 2,
				"message": "MESSAGE"
			}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "logMessage(params:)")
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNotNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert LogMessageParams
		guard let params = manager.params as? LogMessageParams else { XCTFail(); return }
		XCTAssertEqual(params.type, .warning)
		XCTAssertEqual(params.message, "MESSAGE")
	}

	func test_workspace_applyEdit_01() {
		// Execute
		let json = #"""
		{
			"jsonrpc": "2.0",
			"id": "ID",
			"method": "workspace/applyEdit",
			"params": {
				"label": "LABEL",
				"edit": {
					"documentChanges": [
						{
							"textDocument": {
								"uri": "file:///URI",
								"version": 1
							},
							"edits": [
								{
									"range": { "start": { "line": 1, "character": 2 }, "end" : { "line": 3, "character": 4 } },
									"newText": "NEW_TEXT"
								}
							]
						}
					]
				}
			}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "applyEdit(id:params:)")
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNotNil(manager.params)
		XCTAssertEqual(manager.id, .string("ID"))

		// Assert ApplyWorkspaceEditParams
		guard let params = manager.params as? ApplyWorkspaceEditParams else { XCTFail(); return }
		XCTAssertEqual(params.label, "LABEL")
		XCTAssertNil(params.edit.changes)
		XCTAssertEqual(params.edit.documentChanges?.count, 1)
		guard let documentChanges = params.edit.documentChanges?[0] else { XCTFail(); return }
		switch documentChanges {
		case .textDocumentEdit(let textDocumentEdit):
			XCTAssertEqual(textDocumentEdit.textDocument.uri, URL(string: "file:///URI"))
			XCTAssertEqual(textDocumentEdit.textDocument.version.value, 1)
			XCTAssertEqual(textDocumentEdit.edits.count, 1)
			XCTAssertEqual(textDocumentEdit.edits[0].range.start.line, 1)
			XCTAssertEqual(textDocumentEdit.edits[0].range.start.character, 2)
			XCTAssertEqual(textDocumentEdit.edits[0].range.end.line, 3)
			XCTAssertEqual(textDocumentEdit.edits[0].range.end.character, 4)
			XCTAssertEqual(textDocumentEdit.edits[0].newText, "NEW_TEXT")
		default:
			XCTFail()
		}
	}

	func test_workspace_applyEdit_02() {
		// Execute
		let result = ApplyWorkspaceEditResponse(applied: true, failureReason: "FAILURE_REASON")
		manager.applyEdit(id: .string("ID"), result: result)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["id"], "ID")
		XCTAssertEqual(content["result"]?["applied"], true)
		XCTAssertEqual(content["result"]?["failureReason"], "FAILURE_REASON")
	}

	func test_textDocument_publishDiagnostics_01() {
		let json = #"""
		{
			"jsonrpc": "2.0",
			"method": "textDocument/publishDiagnostics",
			"params": {
				"uri": "file:///URI",
				"version": 1,
				"diagnostics": [
					{
						"range": { "start": { "line": 1, "character": 2 }, "end": { "line": 3, "character": 4 } },
						"severity": 1,
						"code": "DIAGNOSTIC_CODE",
						"source": "SOURCE",
						"message": "MESSAGE",
						"tags": [ 1 ],
						"relatedInformation": [
							{
								"location": {
									"uri": "file:///URI",
									"range": { "start": { "line": 5, "character": 6 }, "end": { "line": 7, "character": 8 } }
								},
								"message": "MESSAGE"
							}
						]
					}
				]
			}
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertEqual(manager.function, "publishDiagnostics(params:)")
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNotNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert PublishDiagnosticsParams
		guard let params = manager.params as? PublishDiagnosticsParams else { XCTFail(); return }
		XCTAssertEqual(params.uri, URL(string: "file:///URI")!)
		XCTAssertEqual(params.version, 1)
		XCTAssertEqual(params.diagnostics.count, 1)
		XCTAssertEqual(params.diagnostics[0].range.start.line, 1)
		XCTAssertEqual(params.diagnostics[0].range.start.character, 2)
		XCTAssertEqual(params.diagnostics[0].range.end.line, 3)
		XCTAssertEqual(params.diagnostics[0].range.end.character, 4)
		XCTAssertEqual(params.diagnostics[0].severity, .error)
		switch params.diagnostics[0].code {
		case .string("DIAGNOSTIC_CODE"):
			break
		default:
			XCTFail()
		}
		XCTAssertEqual(params.diagnostics[0].message, "MESSAGE")
		XCTAssertEqual(params.diagnostics[0].tags?.count, 1)
		XCTAssertEqual(params.diagnostics[0].tags?[0], .unnecessary)
		XCTAssertEqual(params.diagnostics[0].relatedInformation?.count, 1)
		XCTAssertEqual(params.diagnostics[0].relatedInformation?[0].location.uri, URL(string: "file:///URI")!)
		XCTAssertEqual(params.diagnostics[0].relatedInformation?[0].location.range.start.line, 5)
		XCTAssertEqual(params.diagnostics[0].relatedInformation?[0].location.range.start.character, 6)
		XCTAssertEqual(params.diagnostics[0].relatedInformation?[0].location.range.end.line, 7)
		XCTAssertEqual(params.diagnostics[0].relatedInformation?[0].location.range.end.character, 8)
		XCTAssertEqual(params.diagnostics[0].relatedInformation?[0].message, "MESSAGE")
	}


	// MARK: - Application message

	func test_cancelRequest_01() {
		// Execute
		let params = CancelParams(id: .number(1))
		application.cancelRequest(params: params)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert ApplicationMessageDelegateStub
		XCTAssertNil(application.function)
		XCTAssertNil(application.result)
		XCTAssertNil(application.error)
		XCTAssertNil(application.id)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["method"], "$/cancelRequest")
		XCTAssertEqual(content["params"]?["id"], 1)
	}

	func test_initialize_01() {
	}

	func test_initialized_01() {
		// Execute
		let params = InitializedParams()
		application.initialized(params: params)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert ApplicationMessageDelegateStub
		XCTAssertNil(application.function)
		XCTAssertNil(application.result)
		XCTAssertNil(application.error)
		XCTAssertNil(application.id)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["method"], "initialized")
		XCTAssertEqual(content["params"]?.isEmpty, true)
	}

	func test_shutdown_01() {
		// Execute
		let params = VoidValue()
		_ = application.shutdown(params: params)

		// Assert send request store
		XCTAssertNotNil(MessageManager.shared.getSendRequest[.number(1)])

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert ApplicationMessageDelegateStub
		XCTAssertNil(application.function)
		XCTAssertNil(application.result)
		XCTAssertNil(application.error)
		XCTAssertNil(application.id)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["method"], "shutdown")
		XCTAssertEqual(content["id"], 1)
		XCTAssertEqual(content["params"]?.isEmpty, true)
	}

	func test_shutdown_02() {
		// Execute
		MessageManager.shared.appendSendRequest(id: .number(1), method: "shutdown", source: application)
		let json = #"""
		{
			"jsonrpc": "2.0",
			"id": 1,
			"result": null
		}
		"""#
		TestConnection.shared.receive(json)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert ApplicationMessageDelegateStub
		XCTAssertEqual(application.function, "shutdown(id:result:)")
		XCTAssertNil(application.result)
		XCTAssertNil(application.error)
		XCTAssertEqual(application.id, .number(1))
	}

	func test_exit_01() {
		// Execute
		let params = VoidValue()
		application.exit(params: params)

		// Assert send request store
		XCTAssertTrue(MessageManager.shared.getSendRequest.isEmpty)

		// Assert MessageManagerDelegateStub
		XCTAssertNil(manager.function)
		XCTAssertNil(manager.cause)
		XCTAssertNil(manager.message)
		XCTAssertNil(manager.params)
		XCTAssertNil(manager.id)

		// Assert ApplicationMessageDelegateStub
		XCTAssertNil(application.function)
		XCTAssertNil(application.result)
		XCTAssertNil(application.error)
		XCTAssertNil(application.id)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["method"], "exit")
		XCTAssertEqual(content["params"]?.isEmpty, true)
	}


	// MARK: - Workspace message

	func test_workspace_didChangeConfiguration_01() {}
	func test_workspace_didChangeWatchedFiles_01() {}
	func test_workspace_symbol_01() {}
	func test_workspace_executeCommand_01() {}


	// MARK: - TextDocument message

	func test_textDocument_didOpen_01() {}
	func test_textDocument_didChange_01() {}
	func test_textDocument_didSave_01() {}
	func test_textDocument_didClose_01() {}
	func test_textDocument_completion_01() {}
	func test_completionItem_resolve_01() {}
	func test_textDocument_hover_01() {}
	func test_textDocument_definition_01() {}
	func test_textDocument_typeDefinition_01() {}
	func test_textDocument_implementation_01() {}
	func test_textDocument_references_01() {}
	func test_textDocument_documentHighlight_01() {}
	func test_textDocument_documentSymbol_01() {}
	func test_textDocument_codeAction_01() {}
	func test_textDocument_rangeFormatting_01() {}
	func test_textDocument_rename_01() {}

}
