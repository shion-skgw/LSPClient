//
//  Array.swift
//  LSPClient
//
//  Created by Shion on 2021/05/29.
//  Copyright © 2021 Shion. All rights reserved.
//

extension Array {

    @inlinable var isNotEmpty: Bool {
        !self.isEmpty
    }

    @inlinable func appending(_ newElements: [Element]) -> [Element] {
        var selfArray = self
        selfArray.append(contentsOf: newElements)
        return selfArray
    }

    @inlinable func map<Key, Value>(_ transform: (Element) throws -> Dictionary<Key, Value>.Element) rethrows -> [Key: Value] {
        return try self.reduce(into: Dictionary<Key, Value>(minimumCapacity: self.count)) {
            let result = try transform($1)
            $0[result.key] = result.value
        }
    }

}
