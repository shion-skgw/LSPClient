//
//  EditorTabView.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

// TODO: Scrollable content size is ambiguous for EditorTabView.

final class EditorTabView: UIScrollView {
    /// Content view
    private(set) weak var contentView: UIStackView!

    /// Get tab items
    var tabItems: [EditorTabItem] {
        contentView.subviews.compactMap({ $0 as? EditorTabItem })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Initialize UIStackView
        let contentView = UIStackView(frame: .zero)
        contentView.axis = .horizontal
        contentView.alignment = .bottom
        contentView.distribution = .fill
        contentView.spacing = 1
        contentView.translatesAutoresizingMaskIntoConstraints = false
        self.addSubview(contentView)
        self.contentView = contentView

        // Layout anchor setting
        self.topAnchor.constraint(equalTo: contentView.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: contentView.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: contentView.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: contentView.trailingAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: contentView.heightAnchor).isActive = true

        // Scroll indicator setting
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    ///
    /// Add tab item
    ///
    /// - Parameter item: Tab item
    ///
    func add(item: EditorTabItem) {
        contentView.addArrangedSubview(item)
    }

    ///
    /// Remove tab item
    ///
    /// - Parameter item: Tab item
    ///
    func remove(item: EditorTabItem) {
        contentView.removeArrangedSubview(item)
        item.removeFromSuperview()
    }

}
