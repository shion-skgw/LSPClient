//
//  LSPConnection.swift
//  LSPClient
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

///
/// LSPConnection
///
protocol LSPConnection: class {

    /// LSPConnection delegate
    var delegate: LSPConnectionDelegate? { set get }

    ///
    /// Connect to language server
    ///
    /// - Parameter host        : Language server host
    /// - Parameter port        : Language server port
    ///
    func connection(host: String, port: Int)

    ///
    /// Disconnect from language server
    ///
    func close()

    ///
    /// Send data
    ///
    /// - Parameter data        : Send data
    /// - Parameter completion  : Send completion handler
    ///
    func send(data: Data, completion: @escaping () -> ())

}


///
/// LSPConnection delegate
///
protocol LSPConnectionDelegate: class {

    ///
    /// Connection error handler
    /// - Parameter cause       : Error cause
    ///
    func connectionError(cause: Error)

    ///
    /// Data receive handler
    ///
    /// - Parameter data        : Received data
    ///
    func didReceive(data: Data)

}
