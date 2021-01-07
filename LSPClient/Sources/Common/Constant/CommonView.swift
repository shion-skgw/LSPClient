//
//  CommonView.swift
//  LSPClient
//
//  Created by Shion on 2021/01/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

struct CommonView {

    static let border: CGFloat = 1.0

    @inlinable
    static var background: UIColor {
        UIColor.secondarySystemBackground
    }

    @inlinable
    static var backgroundBorder: UIColor {
        UIColor.secondarySystemBackground.contrast(0.3)
    }

}
