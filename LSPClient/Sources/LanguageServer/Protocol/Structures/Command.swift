//
//  Command.swift
//  LSPClient
//
//  Created by Shion on 2020/06/12.
//  Copyright © 2020 Shion. All rights reserved.
//

struct Command: Codable {
	let title: String
	let command: String
	let arguments: [AnyValue]?
}
