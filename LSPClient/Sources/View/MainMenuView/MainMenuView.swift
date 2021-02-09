//
//  MainMenuView.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIView

final class MainMenuView: UIView {

    enum Alignment {
        case left
        case right
    }

    var alignment: Alignment = .left
    var spacing: CGFloat = 16.0
    var insetWidth: CGFloat = 16.0

    var contentWidth: CGFloat {
        subviews.reduce(CGFloat.zero, { $0 + $1.frame.width + spacing }) - spacing
    }

    override func layoutSubviews() {
        var position = alignment == .left ? insetWidth : frame.width - contentWidth - insetWidth
        for subview in subviews {
            var subviewFrame = subview.frame
            subviewFrame.origin.x = position
            subviewFrame.origin.y = frame.height.centeringPoint(subviewFrame.height)
            subview.frame = subviewFrame
            position += subviewFrame.width + spacing
        }
    }

}
