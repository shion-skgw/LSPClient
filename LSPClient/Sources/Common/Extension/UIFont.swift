//
//  UIFont.swift
//  LSPClient
//
//  Created by Shion on 2021/02/03.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIFont

extension UIFont {

    static var systemFont: UIFont {
        UIFont.systemFont(ofSize: UIFont.systemFontSize)
    }

    static var smallSystemFont: UIFont {
        UIFont.systemFont(ofSize: UIFont.smallSystemFontSize)
    }

    static var monospacedSystemFont: UIFont {
        UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .regular)
    }

}
