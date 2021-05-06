//
//  ClientCapabilities.swift
//  LSPClient
//
//  Created by Shion on 2020/08/02.
//  Copyright © 2020 Shion. All rights reserved.
//

struct ClientCapabilities: PropertiesType {
    #if DEBUG
    static let resourceName = "ClientCapabilities_test"
    #else
    static let resourceName = "ClientCapabilities"
    #endif
    static var cache: ClientCapabilities?

    let value: AnyValue

    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.value = try container.decode(AnyValue.self)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
