//
//  LSPClientTests.swift
//  LSPClientTests
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import XCTest
@testable import LSPClient

class LSPClientTests: XCTestCase {

	override func setUpWithError() throws {
		// Put setup code here. This method is called before the invocation of each test method in the class.
	}

	override func tearDownWithError() throws {
		// Put teardown code here. This method is called after the invocation of each test method in the class.
	}

	func testExample() throws {
//		let textDocument = TextDocumentIdentifier(uri: DocumentUri(fileURLWithPath: ""))
//		let position = Position(line: 1, character: 2)
//		let params = HoverParams(textDocument: textDocument, position: position)
//		let message = Message.request(.number(1), TEXT_DOCUMENT_HOVER, params)
//		let str = try! MessageManager.shared.test_encode(message)
//		print(str)
//		let str1 = #"""
//		{
//			"jsonrpc": "2.0",
//			"id": 1,
//			"result": {
//				"contents": "string",
//				"range": null
//			}
//		}
//		"""#
//		MessageManager.shared.test_addSendRequest(.number(1), TEXT_DOCUMENT_HOVER, nil)
//		print(try MessageManager.shared.test_decode(str1))
//		let str2 = #"""
//		{
//			"jsonrpc": "2.0",
//			"id": 2,
//			"result": {
//				"contents": {
//					"language": "string",
//					"value": "string"
//				},
//				"range": {
//					"start": {
//						"line": 5,
//						"character": 23
//					},
//					"end": {
//						"line": 6,
//						"character": 0
//					}
//				}
//			}
//		}
//		"""#
//		MessageManager.shared.test_addSendRequest(.number(2), TEXT_DOCUMENT_HOVER, nil)
//		print(try MessageManager.shared.test_decode(str2))
//		let str3 = #"""
//		{
//			"jsonrpc": "2.0",
//			"id": 3,
//			"result": {
//				"contents": {
//					"kind": "markdown",
//					"value": "string"
//				},
//				"range": {
//					"start": {
//						"line": 5,
//						"character": 23
//					},
//					"end": {
//						"line": 6,
//						"character": 0
//					}
//				}
//			}
//		}
//		"""#
//		MessageManager.shared.test_addSendRequest(.number(3), TEXT_DOCUMENT_HOVER, nil)
//		print(try MessageManager.shared.test_decode(str3))
	}

	func testPerformanceExample() throws {
		self.measure {
		}
	}

}
