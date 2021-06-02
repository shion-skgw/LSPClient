//
//  NSAttributedString.swift
//  LSPClient
//
//  Created by Shion on 2021/06/01.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

extension NSAttributedString {

    static func makeAttributes(font: UIFont, color: UIColor? = nil) -> [Key: Any] {
        if let color = color {
            return [.font: font, .foregroundColor: color]
        } else {
            return [.font: font]
        }
    }

    static func makeUnderlineStyle(style: NSUnderlineStyle, color: UIColor? = nil) -> [Key: Any] {
        if let color = color {
            return [.underlineStyle: style.rawValue, .underlineColor: color]
        } else {
            return [.underlineStyle: style.rawValue]
        }
    }

    static func makeStrikeThrough(style: NSUnderlineStyle, color: UIColor? = nil) -> [Key: Any] {
        if let color = color {
            return [.strikethroughStyle: style.rawValue, .strikethroughColor: color]
        } else {
            return [.strikethroughStyle: style.rawValue]
        }
    }

    static func makeParagraphStyle(
            headIndent: CGFloat? = nil, tailIndent: CGFloat? = nil,
            beforeSpacing: CGFloat? = nil, afterSpacing: CGFloat? = nil) -> [Key: Any] {
        let paragraphStyle = NSMutableParagraphStyle()
        if let size = headIndent {
            paragraphStyle.firstLineHeadIndent = size
            paragraphStyle.headIndent = size
        }
        if let size = tailIndent {
            paragraphStyle.tailIndent = size
        }
        if let size = beforeSpacing {
            paragraphStyle.paragraphSpacingBefore = size
        }
        if let size = afterSpacing {
            paragraphStyle.paragraphSpacing = size
        }
        return [.paragraphStyle: paragraphStyle]
    }

}
