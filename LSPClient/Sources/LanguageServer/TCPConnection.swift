//
//  TCPConnection.swift
//  LSPClient
//
//  Created by Shion on 2020/06/09.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation
import Network

final class TCPConnection {

	static let shared = TCPConnection()

	weak var delegate: TCPConnectionDelegate?

	private let queue = DispatchQueue(label: "lsp.connection.tcpconnection")

	private var connection: NWConnection!

	private init() {}

	func connection(host: String, port: Int) {
		let host = NWEndpoint.Host(host)
		let port = NWEndpoint.Port(integerLiteral: UInt16(port))
		connection = NWConnection(host: host, port: port, using: .tcp)
		connection.stateUpdateHandler = {
			[unowned self] (state) in
			switch state {
			case .waiting(let error):
				self.delegate?.connectionError(cause: error)
			case .failed(let error):
				self.delegate?.connectionError(cause: error)
			default:
				break
			}
		}
		connection.start(queue: queue)
		receive()
	}

	private func receive() {
		connection.receive(minimumIncompleteLength: 1, maximumLength: Int(UInt32.max)) {
			[unowned self] (data, _, isComplete, error) in
			if let data = data, !data.isEmpty {
				self.delegate?.didReceive(data: data)
			}

			if isComplete {
				self.close()
			} else if let error = error {
				self.delegate?.connectionError(cause: error)
			} else {
				self.receive()
			}
		}
	}

	func send(data: Data, completion: @escaping () -> ()) {
		connection.send(content: data, completion: .contentProcessed({
			[unowned self, completion] (error) in
			if let error = error {
				self.delegate?.connectionError(cause: error)
			} else {
				completion()
			}
		}))
	}

	func close() {
		connection.cancel()
	}

}

protocol TCPConnectionDelegate: class {

	func connectionError(cause: Error)
	func didReceive(data: Data)

}
