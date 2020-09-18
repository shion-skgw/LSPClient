//
//  UIColor.swift
//  LSPClient
//
//  Created by Shion on 2020/09/16.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit.UIColor

extension UIColor {
    var isBright: Bool {
        hue.brightness > 0.5
    }

    func brightness(_ ratio: CGFloat) -> UIColor {
        let h = hue
        let value = h.brightness + ratio >= 1.0 ? 1.0 : h.brightness + ratio <= 0.0 ? 0.0 : h.brightness + ratio
        return UIColor(hue: h.hue, saturation: h.saturation, brightness: value, alpha: h.alpha)
    }

    var hue: (hue: CGFloat, saturation: CGFloat, brightness: CGFloat, alpha: CGFloat) {
        var hue = CGFloat.zero
        var saturation = CGFloat.zero
        var brightness = CGFloat.zero
        var alpha = CGFloat.zero
        getHue(&hue, saturation: &saturation, brightness: &brightness, alpha: &alpha)
        return (hue: hue, saturation: saturation, brightness: brightness, alpha: alpha)
    }
}
