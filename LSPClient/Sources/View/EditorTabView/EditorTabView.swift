//
//  EditorTabView.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class EditorTabView: UIScrollView {

    private(set) weak var contentView: UIStackView!

    var tabItems: [EditorTabItem] {
        contentView.subviews.compactMap({ $0 as? EditorTabItem })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Initialize UIStackView
        let container = UIStackView(frame: .zero)
        container.axis = .horizontal
        container.alignment = .bottom
        container.distribution = .fill
        container.spacing = 2.0
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        self.contentView = container

        // Layout anchor setting
        self.topAnchor.constraint(equalTo: container.topAnchor).isActive = true
        self.bottomAnchor.constraint(equalTo: container.bottomAnchor).isActive = true
        self.leadingAnchor.constraint(equalTo: container.leadingAnchor).isActive = true
        self.trailingAnchor.constraint(equalTo: container.trailingAnchor).isActive = true
        self.heightAnchor.constraint(equalTo: container.heightAnchor).isActive = true

        // Scroll indicator setting
        self.showsVerticalScrollIndicator = false
        self.showsHorizontalScrollIndicator = false
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    func add(item: EditorTabItem) {
        contentView.addArrangedSubview(item)
    }

    func remove(item: EditorTabItem) {
        contentView.removeArrangedSubview(item)
        item.removeFromSuperview()
    }

}

