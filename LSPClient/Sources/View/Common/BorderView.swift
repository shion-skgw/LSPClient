//
//  BorderView.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIView

final class BorderView: UIView {

    struct Position : OptionSet {
        let rawValue: UInt
        static let top = Position(rawValue: 1 << 0)
        static let left = Position(rawValue: 1 << 1)
        static let right = Position(rawValue: 1 << 2)
        static let bottom = Position(rawValue: 1 << 3)
    }

    var borderPosition: Position = []
    var borderWidth: CGFloat = 1.0
    var borderColor: CGColor = UIColor.black.cgColor

    override func draw(_ rect: CGRect) {
        let cgContext = UIGraphicsGetCurrentContext()!
        cgContext.setFillColor(borderColor)

        var y = CGFloat.zero
        var height = frame.height

        if borderPosition.contains(.top) {
            cgContext.fill(CGRect(x: .zero, y: .zero, width: frame.width, height: borderWidth))
            y = borderWidth
            height -= borderWidth
        }
        if borderPosition.contains(.bottom) {
            cgContext.fill(CGRect(x: .zero, y: frame.height - borderWidth, width: frame.width, height: borderWidth))
            height -= borderWidth
        }

        if borderPosition.contains(.left) {
            cgContext.fill(CGRect(x: .zero, y: y, width: borderWidth, height: height))
        }
        if borderPosition.contains(.right) {
            cgContext.fill(CGRect(x: frame.width - borderWidth, y: y, width: borderWidth, height: height))
        }

        super.draw(rect)
    }

}
