//
//  EditorSetting.swift
//  LSPClient
//
//  Created by Shion on 2020/09/15.
//  Copyright © 2020 Shion. All rights reserved.
//

import CoreGraphics

struct EditorSetting: PropertiesType {
    static let resourceName = "EditorSetting"
    static var cache: EditorSetting?

    let gutterWidth: CGFloat
    let verticalMargin: CGFloat
}
