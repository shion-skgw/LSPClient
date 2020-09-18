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
}

