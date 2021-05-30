//
//  IndentParagraphStyle.swift
//  LSPClient
//
//  Created by Shion on 2021/05/31.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class IndentParagraphStyle: NSParagraphStyle {

    private let headIndentSize: CGFloat
    private let tailIndentSize: CGFloat

    override var firstLineHeadIndent: CGFloat {
        self.headIndentSize
    }

    override var headIndent: CGFloat {
        self.headIndentSize
    }

    override var tailIndent: CGFloat {
        self.tailIndentSize
    }

    init(head: CGFloat, tail: CGFloat = .zero) {
        self.headIndentSize = head
        self.tailIndentSize = tail
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
