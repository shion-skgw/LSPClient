//
//  CollectionDifference.swift
//  LSPClient
//
//  Created by Shion on 2021/05/02.
//  Copyright © 2021 Shion. All rights reserved.
//

extension CollectionDifference {

    @inlinable var isSequential: Bool {
        var insert: Int!
        var remove: Int!

        for diff in self {
            switch diff {
            case .insert(let offset, _, _):
                if insert == nil {
                    insert = offset
                } else if insert == offset - 1 {
                    insert = offset
                } else {
                    return false
                }
            case .remove(let offset, _, _):
                if remove == nil {
                    remove = offset
                } else if remove == offset + 1 {
                    remove = offset
                } else {
                    return false
                }
            }
        }

        return true
    }

}

extension CollectionDifference.Change {

    @inlinable var offset: Int {
        switch self {
        case .insert(let offset, _, _): return offset
        case .remove(let offset, _, _): return offset
        }
    }

}
