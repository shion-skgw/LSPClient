//
//  MessageDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/09/14.
//  Copyright © 2020 Shion. All rights reserved.
//

///
/// MessageDelegate
///
protocol MessageDelegate: class {

    ///
    /// Response receive handler
    ///
    /// - Parameter id          : Request ID
    /// - Parameter context     : Request context
    /// - Parameter result      : Result
    /// - Parameter error       : Error
    /// - Throws                : Unsupported methods
    /// - Returns               : Delete stored request
    ///
    func receiveResponse(id: RequestID, context: MessageManager.RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool

}

extension MessageDelegate {

    ///
    /// Create Result object
    ///
    /// - Parameter result      : Result
    /// - Parameter error       : Error
    /// - Returns               : Result object
    ///
    func toResult<T: ResultType>(_ result: ResultType?, _ error: ErrorResponse?) -> Result<T, ErrorResponse> {
        if let result = result as? T {
            return .success(result)
        } else if let error = error {
            return .failure(error)
        } else {
            fatalError()
        }
    }

}
