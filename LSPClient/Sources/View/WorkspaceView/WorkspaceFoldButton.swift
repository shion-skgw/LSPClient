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
        guard let superviewHeight = superview?.frame.height else {
            return bounds.contains(point)
        }
        var target = bounds
        target.origin.x -= (superviewHeight - bounds.height) / 2.0
        target.origin.y -= (superviewHeight - bounds.width) / 2.0
        target.size.height = superviewHeight
        target.size.width = superviewHeight
        return target.contains(point)
    }

}
