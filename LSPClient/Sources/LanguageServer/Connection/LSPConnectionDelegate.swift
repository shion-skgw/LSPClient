//
//  LSPConnectionDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/09/14.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

///
/// LSPConnection delegate
///
protocol LSPConnectionDelegate: class {

    ///
    /// Connection error handler
    ///
    /// - Parameter cause: Error cause
    ///
    func connectionError(cause: Error)

    ///
    /// Data receive handler
    ///
    /// - Parameter data: Received data
    ///
    func didReceive(data: Data)

}
