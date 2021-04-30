//
//  WorkspaceConfigView.swift
//  LSPClient
//
//  Created by Shion on 2021/03/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceConfigView: UIStackView {

    override init(frame: CGRect) {
        super.init(frame: frame)

        let title = UILabel(frame: CGRect(x: .zero, y: .zero, width: frame.width, height: 32))
        title.text = "Aaaaaaa aaaa Aaaaa Aaa"
        self.addArrangedSubview(title)

        let separator = UIView(frame: CGRect(x: .zero, y: .zero, width: frame.width, height: 0.5))
        separator.backgroundColor = .opaqueSeparator
        self.addArrangedSubview(separator)
    }

    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        self.subviews.forEach() {
            var subviewFrame = $0.frame
            subviewFrame.size.width = self.bounds.size.width
            $0.frame = subviewFrame
        }
    }

}
