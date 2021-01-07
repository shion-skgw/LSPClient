//
//  Token.swift
//  LSPClient
//
//  Created by Shion on 2020/08/22.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.UIColor

struct Token {
    let regex: NSRegularExpression
    let isMultipleLines: Bool
    let textAttribute: [NSAttributedString.Key: Any]

    init(pattern: String, isIgnoreCase: Bool, isMultipleLines: Bool, textColor: UIColor) {
        self.regex = try! NSRegularExpression(pattern: pattern, options: isIgnoreCase ? .caseInsensitive : [])
        self.isMultipleLines = isMultipleLines
        self.textAttribute = [.foregroundColor: textColor]
    }
}
