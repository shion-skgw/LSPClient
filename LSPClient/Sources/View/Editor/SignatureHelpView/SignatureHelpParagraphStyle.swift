//
//  SignatureHelpParagraphStyle.swift
//  LSPClient
//
//  Created by Shion on 2021/05/31.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SignatureHelpParagraphStyle: NSParagraphStyle {

    private let indentSize: CGFloat

    override var firstLineHeadIndent: CGFloat {
        self.indentSize
    }

    override var headIndent: CGFloat {
        self.indentSize
    }

    init(indentSize: CGFloat) {
        self.indentSize = indentSize
        super.init()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

}
