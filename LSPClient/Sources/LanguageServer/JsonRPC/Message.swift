//
//  Message.swift
//  LSPClient
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

enum Message {
    case request(RequestID, String, RequestParamsType)
    case notification(String, NotificationParamsType)
    case response(RequestID, ResultType?)
    case errorResponse(RequestID, ErrorResponse)
}

extension Message: Codable {

    private enum CodingKeys: String, CodingKey {
        case jsonrpc
        case id
        case method
        case params
        case result
        case error
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        if try container.decode(String.self, forKey: .jsonrpc) != "2.0" {
            throw DecodingError.dataCorruptedError(forKey: .jsonrpc, in: container, debugDescription: "TODO")
        }

        let id = try container.decodeIfPresent(RequestID.self, forKey: .id)
        let method = try container.decodeIfPresent(String.self, forKey: .method)
        let hasResult = container.contains(.result)
        let hasError = container.contains(.error)

        switch (id, method, hasResult, hasError) {
        case (let id?, let method?, false, false):
            /* Request */
            guard let paramsType = REQUEST_PARAMS_TYPE[method] else {
                throw MessageDecodingError.unsupportedMethod(id, method)
            }
            let params = try paramsType.init(from: container.superDecoder(forKey: .params))
            self = .request(id, method, params)

        case (nil, let method?, false, false):
            /* Notification */
            guard let paramsType = NOTIFICATION_PARAMS_TYPE[method] else {
                throw MessageDecodingError.unsupportedMethod(nil, method)
            }
            let params = try paramsType.init(from: container.superDecoder(forKey: .params))
            self = .notification(method, params)

        case (let id?, nil, true, false):
            /* Response */
            guard let method = (decoder.userInfo[.storedRequest] as? StoredRequest)?(id) else {
                throw MessageDecodingError.unknownRequestID
            }
            guard let resultType = RESPONSE_RESULT_TYPE[method] else {
                throw MessageDecodingError.unsupportedMethod(id, method)
            }
            let result = try resultType.init(from: container.superDecoder(forKey: .result))
            self = .response(id, result)

        case (let id?, nil, false, true):
            /* Error response */
            guard (decoder.userInfo[.storedRequest] as? StoredRequest)?(id) != nil else {
                throw MessageDecodingError.unknownRequestID
            }
            let error = try container.decode(ErrorResponse.self, forKey: .error)
            self = .errorResponse(id, error)

        default:
            throw DecodingError.dataCorruptedError(container.codingPath, "TODO")
        }
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode("2.0", forKey: .jsonrpc)

        switch self {
        case .request(let id, let method, let params):
            /* Request */
            try container.encode(id, forKey: .id)
            try container.encode(method, forKey: .method)
            try params.encode(to: container.superEncoder(forKey: .params))

        case .notification(let method, let params):
            /* Notification */
            try container.encode(method, forKey: .method)
            try params.encode(to: container.superEncoder(forKey: .params))

        case .response(let id, let result):
            /* Response */
            try container.encode(id, forKey: .id)
            if let result = result {
                try result.encode(to: container.superEncoder(forKey: .result))
            } else {
                try container.encodeNil(forKey: .result)
            }

        case .errorResponse(let id, let error):
            /* Error response */
            try container.encode(id, forKey: .id)
            try error.encode(to: container.superEncoder(forKey: .error))
        }
    }

}
