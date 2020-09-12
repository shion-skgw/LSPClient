//
//  RequiredValue.swift
//  LSPClient
//
//  Created by Shion on 2020/06/12.
//  Copyright © 2020 Shion. All rights reserved.
//

struct RequiredValue<T: Codable> {
    let value: T?

    init(_ value: T?) {
        self.value = value
    }
}

extension RequiredValue: Codable {
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        self.init(try container.decode(T?.self))
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(value)
    }
}
