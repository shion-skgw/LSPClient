//
//  EditorTabCloseButton.swift
//  LSPClient
//
//  Created by Shion on 2021/02/23.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class EditorTabCloseButton: UIButton {

    /// Document URI
    var uri: DocumentUri

    override init(frame: CGRect) {
        // Initialize
        self.uri = .bluff
        super.init(frame: frame)

        // Remove all subviews
        self.subviews.forEach({ $0.removeFromSuperview() })

        // Set button icon
        self.setImage(UIImage.closeIcon(pointSize: 16, weight: .regular), for: .normal)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
