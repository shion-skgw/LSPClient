//
//  CompletionDetailView.swift
//  LSPClient
//
//  Created by Shion on 2021/05/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionDetailView: UIView {
    /// Completion text label
    private(set) weak var completionLabel: UILabel!
    /// Detail text label
    private(set) weak var detailLabel: UILabel!

    private let leftMargin: CGFloat = 4
    private let rightMargin: CGFloat = 2

    override init(frame: CGRect) {
        super.init(frame: frame)

        let completionLabel = UILabel(frame: .zero)
        self.addSubview(completionLabel)
        self.completionLabel = completionLabel

        let detailLabel = UILabel(frame: .zero)
        detailLabel.numberOfLines = .zero
        self.addSubview(detailLabel)
        self.detailLabel = detailLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func layoutSubviews() {
        var completionLabelFrame = CGRect(origin: .zero, size: bounds.size)
        completionLabelFrame.origin.x = leftMargin
        completionLabelFrame.size.width -= leftMargin + rightMargin
        completionLabelFrame.size.height = completionLabel.font.pointSize * 1.6
        completionLabel.frame = completionLabelFrame

        var detailLabelFrame = CGRect(origin: .zero, size: bounds.size)
        detailLabelFrame.origin.x = leftMargin
        detailLabelFrame.origin.y = completionLabelFrame.maxY
        detailLabelFrame.size.width -= leftMargin + rightMargin
        detailLabelFrame.size.height -= completionLabelFrame.maxY
        detailLabel.frame = detailLabelFrame
    }

    func set(codeStyle: CodeStyle) {
        backgroundColor = codeStyle.backgroundColor

        completionLabel.font = codeStyle.font.uiFont
        completionLabel.textColor = codeStyle.fontColor.text.uiColor

        detailLabel.font = .systemFont(ofSize: codeStyle.font.size)
        detailLabel.textColor = codeStyle.fontColor.text.uiColor
    }

    func set(label: String, deprecated: Bool, detail: String) {
        let labelAttributes: [NSAttributedString.Key: Any] = [
            .font: self.completionLabel.font ?? .systemFont,
            .foregroundColor: self.completionLabel.textColor ?? .black,
            .strikethroughStyle: deprecated ? 1 : 0
        ]
        self.completionLabel.attributedText = NSAttributedString(string: label, attributes: labelAttributes)
        self.detailLabel.text = detail
    }

}
