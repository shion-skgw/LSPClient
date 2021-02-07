//
//  URL.swift
//  LSPClient
//
//  Created by Shion on 2021/02/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

extension URL {

    static let bluff = URL(string: "!")!

    @inlinable func hasPrefix(_ prefix: URL) -> Bool {
        return self.absoluteString.hasPrefix(prefix.absoluteString)
    }

}
