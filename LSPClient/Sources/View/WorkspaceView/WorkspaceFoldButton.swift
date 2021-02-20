//
//  WorkspaceFoldButton.swift
//  LSPClient
//
//  Created by Shion on 2021/02/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceFoldButton: UIButton {

    private let appearance = WorkspaceAppearance.self

    var isFold: Bool {
        didSet {
            self.setImage(isFold ? .triangleRight : .triangleDown, for: .normal)
        }
    }

    override init(frame: CGRect) {
        self.isFold = false
        super.init(frame: frame)

        var insets = UIEdgeInsets.zero
        insets.top = frame.height.centeringPoint(appearance.foldMarkSize.height)
        insets.bottom = insets.top
        insets.left = frame.width.centeringPoint(appearance.foldMarkSize.width)
        insets.right = insets.left
        self.contentEdgeInsets = insets

        self.tintColor = appearance.foldMarkColor

        self.setImage(.triangleDown, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
