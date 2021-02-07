//
//  AppearanceSetting.swift
//  LSPClient
//
//  Created by Shion on 2021/02/07.
//  Copyright © 2021 Shion. All rights reserved.
//

import CoreGraphics

struct AppearanceSetting: PropertiesType {
    static let resourceName = "AppearanceSetting"
    static var cache: AppearanceSetting?

    let mainMenu: MainMenu
    let editor: Editor
    let workspace: Workspace
}

extension AppearanceSetting {

    struct MainMenu: Codable {
    }

    struct Editor: Codable {
    }

    struct Workspace: Codable {
        let rowHeight: CGFloat
        let indentWidth: CGFloat
        let foldButtonWidth: CGFloat
        let foldButtonHeight: CGFloat
        let iconSize: CGFloat
        let iconAreaWidth: CGFloat
        let gutterMargin: CGFloat
    }

}
