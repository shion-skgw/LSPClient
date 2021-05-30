//
//  FloatingViewType.swift
//  LSPClient
//
//  Created by Shion on 2021/05/29.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

protocol FloatingViewType: UIViewController {

    var viewSize: CGSize { get }

}

extension FloatingViewType {

    var borderWidth: CGFloat {
        0.5
    }

    var cornerRadius: CGFloat {
        3
    }

    func borderSetting() {
        view.layer.borderWidth = borderWidth
        view.layer.cornerRadius = cornerRadius
    }

    func show(caretRect: CGRect) {
        view.frame.origin = viewOrigin(caretRect)
        view.isHidden = false
    }

    func hide() {
        view.isHidden = true
    }

    private func viewOrigin(_ caretRect: CGRect) -> CGPoint {
        guard let superViewBounds = parent?.view.bounds else {
            fatalError()
        }

        // Calc view frame
        let origin = CGPoint(x: caretRect.minX - 40, y: caretRect.maxY + 4)
        var frame = CGRect(origin: origin, size: viewSize)

        // Correcting X,Y
        if superViewBounds.maxX - 6 < frame.maxX {
            frame.origin.x -= frame.maxX - superViewBounds.maxX + 6
        }
        if superViewBounds.maxY - 6 < frame.maxY {
            frame.origin.y = caretRect.minY - frame.height - 4
        }

        return frame.origin
    }

}
