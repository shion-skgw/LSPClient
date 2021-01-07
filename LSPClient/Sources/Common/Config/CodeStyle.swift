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

    var font: Font
    var fontColor: FontColor
    var backgroundColor: Color
    var tabSize: Int
    var useHardTab: Bool
    var showInvisibles: Bool
    var lineHighlight: Bool

    init() {
        self.font = Font()
        self.fontColor = FontColor()
        self.backgroundColor = Color.white
        self.tabSize = 4
        self.useHardTab = true
        self.showInvisibles = true
        self.lineHighlight = true
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

        init(name: String, size: CGFloat) {
            self.name = name
            self.size = size
        }

        init() {
            let font = UIFont.systemFont(ofSize: UIFont.systemFontSize)
            self.init(name: font.familyName, size: font.pointSize)
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
                self.hue = newValue.hue.hue
                self.saturation = newValue.hue.saturation
                self.brightness = newValue.hue.brightness
                self.alpha = newValue.hue.alpha
            }
        }

        static var black: Color {
            self.init(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
        }

        static var white: Color {
            self.init(hue: 0.0, saturation: 0.0, brightness: 1.0, alpha: 1.0)
        }

        init(hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
            self.hue = hue
            self.saturation = saturation
            self.brightness = brightness
            self.alpha = alpha
        }

        init() {
            self.init(hue: 0.0, saturation: 0.0, brightness: 0.0, alpha: 1.0)
        }
    }

    struct FontColor: Codable {
        var text: Color
        var keyword: Color
        var function: Color
        var number: Color
        var string: Color
        var comment: Color
        var invisibles: Color

        init(text: Color, keyword: Color, function: Color, number: Color, string: Color, comment: Color, invisibles: Color) {
            self.text = text
            self.keyword = keyword
            self.function = function
            self.number = number
            self.string = string
            self.comment = comment
            self.invisibles = invisibles
        }

        init() {
            let color = Color.black
            self.init(text: color, keyword: color, function: color, number: color, string: color, comment: color, invisibles: color)
        }
    }

}
