//
//  WorkspaceFoldButton.swift
//  LSPClient
//
//  Created by Shion on 2021/02/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceFoldButton: UIButton {
    /// Folding state
    var isFold: Bool {
        didSet {
            self.setImage(isFold ? .triangleRight : .triangleDown, for: .normal)
        }
    }

    override init(frame: CGRect) {
        // Initialize
        self.isFold = false
        super.init(frame: frame)

        // Set fold icon image
        self.setImage(.triangleDown, for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
