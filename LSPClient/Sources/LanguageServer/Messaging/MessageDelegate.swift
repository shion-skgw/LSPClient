//
//  MessageDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/09/14.
//  Copyright © 2020 Shion. All rights reserved.
//

protocol MessageDelegate: class {

    func receiveResponse(id: RequestID, context: RequestContext, result: ResultType?, error: ErrorResponse?) throws -> Bool

}

extension MessageDelegate {

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
