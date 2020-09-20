//
//  Token.swift
//  LSPClient
//
//  Created by Shion on 2020/08/22.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.UIColor

struct Token {
    let type: TokenType
    let regex: NSRegularExpression
    let isMultipleLines: Bool
    let textAttribute: [NSAttributedString.Key: Any]

    init(type: TokenType, pattern: String, isIgnoreCase: Bool, isMultipleLines: Bool) {
        self.type = type
        self.regex = try! NSRegularExpression(pattern: pattern, options: isIgnoreCase ? .caseInsensitive : [])
        self.isMultipleLines = isMultipleLines
        self.textAttribute = [.foregroundColor: type.color]
    }
}

extension Token {
    enum TokenType {
        case keyword
        case function
        case number
        case string
        case comment

        var color: UIColor {
            switch self {
            case .keyword : return UIColor.green
            case .function: return UIColor.green
            case .number  : return UIColor.green
            case .string  : return UIColor.green
            case .comment : return UIColor.green
            }
        }
    }
}
