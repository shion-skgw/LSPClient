//
//  FloatingViewType.swift
//  LSPClient
//
//  Created by Shion on 2021/05/29.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

protocol FloatingViewType: UIViewController {

    associatedtype LSPResultType: ResultType

    func willShow(_ result: LSPResultType) -> Bool

}

extension FloatingViewType {

    var viewSize: CGSize {
        CGSize(width: 260, height: 180)
    }

    func show(with result: LSPResultType, caretRect: CGRect) {
        guard willShow(result) else {
            return
        }
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
