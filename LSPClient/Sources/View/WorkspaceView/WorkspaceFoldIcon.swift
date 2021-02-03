//
//  WorkspaceFoldIcon.swift
//  LSPClient
//
//  Created by Shion on 2021/02/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceFoldIcon: UIImageView {

    var isFold: Bool = false {
        didSet {
            self.image = isFold ? .triangleRight : .triangleDown
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

    func addTapAction(_ target: Any?, action: Selector) {
        let gestureRecognizer = UITapGestureRecognizer(target: target, action: action)
        gestureRecognizer.cancelsTouchesInView = false
        self.isUserInteractionEnabled = true
        self.addGestureRecognizer(gestureRecognizer)
    }

}
