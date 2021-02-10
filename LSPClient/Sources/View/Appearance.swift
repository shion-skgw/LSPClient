//
//  Appearance.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

struct Appearance {

    static let mainMenuHeight: CGFloat = 48
    static var mainMenuColor: UIColor {
        .secondarySystemBackground
    }
    static let sidebarWidth: CGFloat = 48
    static var sidebarColor: UIColor {
        .secondarySystemBackground
    }
    static let viewMargin: CGFloat = 1

    struct MainMenu {
        static let buttonSize: CGSize = CGSize(width: 48, height: 48)
        static let iconPointSize: CGFloat = 24
        static var iconColor: UIColor {
            .systemBlue
        }
    }

    struct EditorTab {
        static var viewHeight: CGFloat {
            UIFont.systemFontSize * 1.4
        }
        static let tabMargin: CGFloat = 2
        static var tabSize: CGSize {
            CGSize(width: 160, height: viewHeight - tabMargin)
        }
    }

    struct Editor {
    }

    struct Sidebar {
        static let buttonSize: CGSize = CGSize(width: 48, height: 48)
        static let iconPointSize: CGFloat = 24
        static var iconColor: UIColor {
            .systemBlue
        }
    }

    struct Workspace {
    }

}
