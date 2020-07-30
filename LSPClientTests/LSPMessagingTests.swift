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

	var messageManager: MessageManagerDelegateStub!
	var application: ApplicationResponceDelegateStub!
	var workspace: WorkspaceResponceDelegateStub!
	var textDocument: TextDocumentResponceDelegateStub!

	override func setUp() {
		self.messageManager = MessageManagerDelegateStub()
		self.application = ApplicationResponceDelegateStub()
		self.workspace = WorkspaceResponceDelegateStub()
		self.textDocument = TextDocumentResponceDelegateStub()
		MessageManager.shared.delegate = self.messageManager
		MessageManager.shared.connection = TestConnection.shared
		TestConnection.shared.delegate = MessageManager.shared
	}


	// MARK: - Coding error

	func test_invalidJson_01() {
		// Execute
		let json = #"{jsonrpc = 2.0}"#
		TestConnection.shared.receive(json)

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "messageError(cause:message:)")
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNotNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert Error
		guard let cause = messageManager.cause else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "showMessage(params:)")
		XCTAssertNotNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert ShowMessageParams
		guard let params = messageManager.params as? ShowMessageParams else { XCTFail(); return }
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

		// Assert MessageManagerDelegate
		XCTAssertEqual(messageManager.function, "showMessageRequest(id:params:)")
		XCTAssertNotNil(messageManager.params)
		XCTAssertEqual(messageManager.id, .string("ID"))
		XCTAssertNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert ShowMessageParams
		guard let params = messageManager.params as? ShowMessageRequestParams else { XCTFail(); return }
		XCTAssertEqual(params.type, .error)
		XCTAssertEqual(params.message, "MESSAGE")
		XCTAssertEqual(params.actions?.count, 1)
		XCTAssertEqual(params.actions?[0].title, "TITLE0")
	}

	func test_window_showMessageRequest_02() {
		// Execute
		ServerMessage.shared.showMessageRequest(id: .string("ID"), result: nil)

		// Assert MessageManagerDelegate
		XCTAssertNil(messageManager.function)
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["id"], "ID")
		XCTAssertEqual(content["result"].isVoid, true)
	}

	func test_window_showMessageRequest_03() {
		// Execute
		let result = MessageActionItem(title: "TITLE")
		ServerMessage.shared.showMessageRequest(id: .string("ID"), result: result)

		// Assert MessageManagerDelegate
		XCTAssertNil(messageManager.function)
		XCTAssertNil(messageManager.params)
		XCTAssertNil(messageManager.id)
		XCTAssertNil(messageManager.cause)
		XCTAssertNil(messageManager.message)

		// Assert content
		let content = dictionary(TestConnection.shared.sendContent)
		XCTAssertEqual(content["jsonrpc"], "2.0")
		XCTAssertEqual(content["id"], "ID")
		XCTAssertEqual(content["result"]["title"], "TITLE")
	}

	func test_window_logMessage_01() {}

	func test_workspace_applyEdit_01() {}

	func test_textDocument_publishDiagnostics_01() {}


	// MARK: - Application message

	func test_cancelRequest_01() {}
	func test_initialize_01() {}
	func test_initialized_01() {}
	func test_shutdown_01() {}
	func test_exit_01() {}


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
