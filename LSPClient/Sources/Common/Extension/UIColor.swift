//
//  UIColor.swift
//  LSPClient
//
//  Created by Shion on 2020/09/16.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.UIColor

extension UIColor {

    struct Hue {
        let hue: CGFloat
        let saturation: CGFloat
        let brightness: CGFloat
        let alpha: CGFloat
    }

    var hue: Hue {
        var hue = CGFloat.zero
        var saturation = CGFloat.zero
        var brightness = CGFloat.zero
        var alpha = CGFloat.zero
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return Hue(hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }

    var isBright: Bool {
        // algorithm from: http://www.w3.org/WAI/ER/WD-AERT/#color-contrast
        var red = CGFloat.zero
        var green = CGFloat.zero
        var blue = CGFloat.zero
        getRed(&red, green: &green, blue: &blue, alpha: nil)
        return (red * 299.0) + (green * 587.0) + (blue * 114.0) > 500.0
    }

    func contrast(_ ratio: CGFloat) -> UIColor {
        var value = hue.brightness + (isBright ? ratio * -1.0 : ratio)
        value = value >= 1.0 ? 1.0 : value <= 0.0 ? 0.0 : value
        return UIColor(hue: hue.hue, saturation: hue.saturation, brightness: value, alpha: hue.alpha)
    }

}
