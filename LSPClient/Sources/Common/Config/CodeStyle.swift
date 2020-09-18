//
//  CodeStyle.swift
//  LSPClient
//
//  Created by Shion on 2020/09/15.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

struct CodeStyle: ConfigType {
    static let configKey = "CodeStyle"
    static var cache: CodeStyle?

    var backgroundColor: Color
    var font: Font
    var fontColor: Color
    var showInvisibles: Bool
    var invisiblesFontColor: Color
    var tabSize: Int
    var useHardTab: Bool
    var lineHighlight: Bool

    init() {
        backgroundColor = Color(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
        font = Font(name: UIFont.systemFont(ofSize: 12.0).familyName, size: 12.0)
        fontColor = Color(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
        tabSize = 4
        useHardTab = true
        showInvisibles = true
        invisiblesFontColor = fontColor
        lineHighlight = true
    }
}

extension CodeStyle {

    struct Font: Codable {
        var name: String
        var size: CGFloat

        var uiFont: UIFont {
            get {
                UIFont(name: name, size: size) ?? UIFont.systemFont(ofSize: size)
            }
            set {
                name = newValue.fontName
                size = newValue.pointSize
            }
        }
    }

    struct Color: Codable {
        var hue: CGFloat
        var saturation: CGFloat
        var brightness: CGFloat
        var alpha: CGFloat

        var uiColor: UIColor {
            get {
                UIColor(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
            }
            set {
                hue = newValue.hue.hue
                saturation = newValue.hue.saturation
                brightness = newValue.hue.brightness
                alpha = newValue.hue.alpha
            }
        }
    }

}
