//
//  ErrorResponse.swift
//  LSPClient
//
//  Created by Shion on 2020/06/08.
//  Copyright © 2020 Shion. All rights reserved.
//

enum ErrorCodes: Int, Codable {
    case parseError = -32700
    case invalidRequest = -32600
    case methodNotFound = -32601
    case invalidParams = -32602
    case internalError = -32603
    case serverErrorStart = -32099
    case serverErrorEnd = -32000
    case serverNotInitialized = -32002
    case unknownErrorCode = -32001

    case requestCancelled = -32800

    case unknownProtocolVersion = 1
}

struct ErrorResponse: Error, Codable {
    let code: ErrorCodes
    let message: String
    let data: AnyValue?
}
