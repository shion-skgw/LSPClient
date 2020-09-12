//
//  ExecuteCommand.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Execute a command (workspace/executeCommand)

struct ExecuteCommandParams: RequestParamsType {
    let command: String
    let arguments: [AnyValue]?
}
