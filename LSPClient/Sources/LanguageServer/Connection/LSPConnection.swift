//
//  LSPConnection.swift
//  LSPClient
//
//  Created by Shion on 2020/07/30.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

protocol LSPConnection: class {
	func connection(host: String, port: Int)
	func send(data: Data, completion: @escaping () -> ())
	func close()
}

protocol LSPConnectionDelegate: class {
	func connectionError(cause: Error)
	func didReceive(data: Data)
}
