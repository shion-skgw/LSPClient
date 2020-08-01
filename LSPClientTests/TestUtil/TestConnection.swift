//
//  TestConnection.swift
//  LSPClientTests
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import XCTest
import Foundation
import Network
@testable import LSPClient

let REQUEST_HEADERS	= "Content-Length: %d\r\nContent-Type: application/vscode-jsonrpc; charset=utf8\r\n\r\n"

class TestConnection: LSPConnection {

	static var shared = TestConnection()

	weak var delegate: LSPConnectionDelegate?

	var sendData: String!

	var sendContent: String {
		guard let firstIndex = sendData.firstIndex(of: "{") else {
			fatalError()
		}
		return String(sendData[firstIndex..<sendData.endIndex])
	}

	func send(data: Data, completion: @escaping () -> ()) {
		sendData = String(data: data, encoding: .utf8)
		completion()
	}

	func receive(_ str: String) {
		let data = (REQUEST_HEADERS + str).data(using: .utf8)!
		delegate?.didReceive(data: data)
	}

	func connection(host: String, port: Int) {}

	func connectionError() {
		let error = NWError.posix(POSIXErrorCode.E2BIG)
		delegate?.connectionError(cause: error)
	}

	func close() {}

}
