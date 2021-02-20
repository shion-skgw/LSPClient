//
//  Appearance.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

struct RootAppearance {
    static let separatorWeight = CGFloat(1)
    static let separatorColor = UIColor.opaqueSeparator
    static let backgroundColor = UIColor.systemBackground
}

struct MainMenuAppearance {
    static let viewSize = CGSize(width: -1, height: 48)
    static let viewColor = UIColor.secondarySystemBackground
    static let buttonSize = CGSize(width: 48, height: 48)
    static let iconPointSize = CGFloat(18)
    static let iconWeight = UIImage.SymbolWeight.light
    static let iconColor = UIColor.systemBlue
}

struct SidebarMenuAppearance {
    static let viewSize = CGSize(width: 48, height: -1)
    static let viewColor = UIColor.secondarySystemBackground
    static let buttonSize = CGSize(width: 48, height: 48)
    static let iconPointSize = CGFloat(18)
    static let iconWeight = UIImage.SymbolWeight.light
    static let iconColor = UIColor.systemBlue
}

struct WorkspaceAppearance {
    static let menuViewSize = CGSize(width: -1, height: 31)
    static let menuViewColor = UIColor.secondarySystemBackground
    static let menuButtonSize = CGSize(width: 30, height: 30)
    static let menuIconPointSize = CGFloat(18)
    static let menuIconWeight = UIImage.SymbolWeight.light
    static let menuIconColor = UIColor.systemBlue

    static let separatorWeight = CGFloat(1)
    static let separatorColor = UIColor.opaqueSeparator

    static let cellHeight = UIFont.systemFontSize * 2.5

    static let horizontalMargin = CGFloat(8)
    static let indentWidth = CGFloat(14)

    static let foldButtonSize = CGSize(width: UIFont.systemFontSize * 3, height: cellHeight)
    static let foldMarkSize = CGSize(width: 10, height: 10)
    static let foldMarkColor = UIColor.label

    static let fileIconSize = CGSize(width: 22, height: cellHeight)
    static let fileIconPointSize = CGFloat(15)
    static let fileIconWeight = UIImage.SymbolWeight.light
    static let fileIconColor = UIColor.label

    static let fileNameFont = UIFont.systemFont
    static let fileNameFontColor = UIColor.label
}

struct EditorTabAppearance {
}

struct EditorAppearance {
}

struct ConsoleAppearance {
}

struct DiagnosticAppearance {
}
