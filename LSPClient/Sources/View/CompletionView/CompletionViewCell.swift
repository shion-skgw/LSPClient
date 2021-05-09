//
//  CompletionViewCell.swift
//  LSPClient
//
//  Created by Shion on 2021/05/08.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewCell: UITableViewCell {
    /// Icon image view
    private(set) weak var symbolIcon: UIImageView!
    /// completion text label
    private(set) weak var completionLabel: UILabel!

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        guard let identifier = CompletionViewCellIdentifier(identifier: reuseIdentifier ?? "") else {
            fatalError()
        }

        // Initialize
        super.init(style: style, reuseIdentifier: reuseIdentifier)

        // Remove all subviews
        self.contentView.subviews.forEach({ $0.removeFromSuperview() })

        // Icon image view
        let symbolIcon = createSymbolIcon(identifier)
        self.contentView.addSubview(symbolIcon)
        self.symbolIcon = symbolIcon

        // File name label
        let completionLabel = createCompletionLabel(identifier, symbolIcon.frame)
        self.contentView.addSubview(completionLabel)
        self.completionLabel = completionLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func createSymbolIcon(_ identifier: CompletionViewCellIdentifier) -> UIImageView {
        return .init()
    }

    private func createCompletionLabel(_ identifier: CompletionViewCellIdentifier, _ symbolIconFrame: CGRect) -> UILabel {
        return .init()
    }

}
