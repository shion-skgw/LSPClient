//
//  Function.swift
//  LSPClient
//
//  Created by Shion on 2021/01/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

@inlinable func localizedStandardOrder(_ url1: URL, _ url2: URL) -> Bool {
    return url1.path.localizedStandardCompare(url2.path) == .orderedAscending
}

