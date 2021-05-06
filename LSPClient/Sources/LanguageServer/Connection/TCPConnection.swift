//
//  TCPConnection.swift
//  LSPClient
//
//  Created by Shion on 2020/06/09.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation
import Network

///
/// TCPConnection
///
final class TCPConnection: LSPConnection {
    /// TCPConnection shared instance
    static let shared = TCPConnection()
    /// LSPConnection delegate
    weak var delegate: LSPConnectionDelegate!
    /// NWConnection
    private var connection: NWConnection!
    /// DispatchQueue
    private let queue = DispatchQueue(label: "lsp.connection.tcpconnection")

    ///
    /// Initialize
    ///
    private init() {
    }

    ///
    /// Connect to language server
    ///
    /// - Parameter host: Language server host
    /// - Parameter port: Language server port
    ///
    func connection(host: String, port: Int) {
        // Access point
        let host = NWEndpoint.Host(host)
        let port = NWEndpoint.Port(integerLiteral: UInt16(port))

        // Connection initialization
        connection = NWConnection(host: host, port: port, using: .tcp)
        connection.stateUpdateHandler = {
            state in
            switch state {
            case .waiting(let error):
                self.connectionError(error)
            case .failed(let error):
                self.connectionError(error)
            default:
                break
            }
        }

        // Start connection
        connection.start(queue: queue)
        receive()
    }

    ///
    /// Disconnect from language server
    ///
    func close() {
        connection.cancel()
    }

    ///
    /// Receive data
    ///
    private func receive() {
        connection.receive(minimumIncompleteLength: 1, maximumLength: Int(UInt32.max)) {
            data, _, isComplete, error in
            if let data = data, !data.isEmpty {
                self.didReceive(data)
            }

            if isComplete {
                self.close()
            } else if let error = error {
                self.connectionError(error)
            } else {
                self.receive()
            }
        }
    }

    ///
    /// Send data
    ///
    /// - Parameter data      : Send data
    /// - Parameter completion: Send completion handler
    ///
    func send(data: Data, completion: @escaping () -> ()) {
        connection.send(content: data, completion: .contentProcessed {
            [completion] error in
            if let error = error {
                self.connectionError(error)
            } else {
                completion()
            }
        })
    }

    private func connectionError(_ cause: Error) {
        DispatchQueue.main.async {
            self.delegate.connectionError(cause: cause)
        }
    }

    private func didReceive(_ data: Data) {
        DispatchQueue.main.async {
            self.delegate.didReceive(data: data)
        }
    }

}
