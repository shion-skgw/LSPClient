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
        guard let targetHeight = superview?.bounds.height else {
            return bounds.contains(point)
        }
        var target = CGRect(x: .zero, y: .zero, width: targetHeight * 1.5, height: targetHeight)
        target.origin.x -= target.width.centeringPoint(bounds.width)
        target.origin.y -= target.height.centeringPoint(bounds.height)
        return target.contains(point)
    }

}
