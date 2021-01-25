//
//  String.swift
//  LSPClient
//
//  Created by Shion on 2020/09/16.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

extension String {
    var range: NSRange {
        NSMakeRange(0, utf16.count)
    }
    static let null = "\u{0000}"
    static let tab = "\u{0009}"
    static let spase = "\u{0020}"
    static let lineFeed = "\u{000A}"
    static let delete = "\u{007F}"
}

