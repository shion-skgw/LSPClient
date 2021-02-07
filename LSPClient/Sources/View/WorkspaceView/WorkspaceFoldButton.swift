//
//  WorkspaceFoldButton.swift
//  LSPClient
//
//  Created by Shion on 2021/02/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceFoldButton: UIButton {

    var isFold: Bool = false {
        didSet {
            self.setImage(isFold ? .triangleRight : .triangleDown, for: .normal)
        }
    }

    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        guard let superviewBounds = superview?.bounds else {
            return bounds.contains(point)
        }
        var target = bounds
        target.origin.x -= superviewBounds.height.centeringPoint(bounds.height)
        target.origin.y -= superviewBounds.height.centeringPoint(bounds.width)
        target.size.height = superviewBounds.height
        target.size.width = superviewBounds.height
        return target.contains(point)
    }

}
