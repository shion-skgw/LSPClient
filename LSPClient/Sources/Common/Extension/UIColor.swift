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
        return (red * 299) + (green * 587) + (blue * 114) > 500
    }

    func contrast(_ ratio: CGFloat) -> UIColor {
        let saturateRatio = (isBright ? ratio * -1 : ratio) / 3
        let saturate = max(min(hue.saturation + saturateRatio, 1), .zero)
        let brightRatio = isBright ? ratio * -1 : ratio
        let bright = max(min(hue.brightness + brightRatio, 1), .zero)
        return UIColor(hue: hue.hue, saturation: saturate, brightness: bright, alpha: hue.alpha)
    }

}
