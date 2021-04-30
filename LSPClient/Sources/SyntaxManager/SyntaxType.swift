//
//  SyntaxType.swift
//  LSPClient
//
//  Created by Shion on 2021/04/30.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

enum SyntaxType: String, Codable {
    case keyword
    case function
    case number
    case string
    case comment
}
