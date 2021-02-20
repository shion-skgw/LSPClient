//
//  UIButton.swift
//  LSPClient
//
//  Created by Shion on 2021/02/13.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit.UIButton

extension UIButton {

    @inlinable func addAction(_ handler: @escaping UIActionHandler, for controlEvents: UIControl.Event) {
        addAction(UIAction(handler: handler), for: controlEvents)
    }

    static func closeButton(frame: CGRect, pointSize: CGFloat, weight: UIImage.SymbolWeight) -> UIButton {
        let config = UIImage.SymbolConfiguration(pointSize: pointSize, weight: weight)
        let icon = UIImage(systemName: "xmark.circle.fill", withConfiguration: config)!.withRenderingMode(.alwaysOriginal)
        let closeButton = UIButton(frame: frame)
        closeButton.setImage(icon.withTintColor(UIColor.label.withAlphaComponent(0.3)), for: .normal)
        closeButton.setImage(icon.withTintColor(UIColor.label.withAlphaComponent(0.5)), for: .highlighted)
        return closeButton
    }

}
