//
//  EditorTabView.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class EditorTabView: UIScrollView {

    private(set) weak var container: UIStackView!

    var tabItems: [EditorTabItem] {
        container.subviews.compactMap({ $0 as? EditorTabItem })
    }

    override init(frame: CGRect) {
        super.init(frame: frame)

        // Initialize UIStackView
        let container = UIStackView(frame: .zero)
        container.distribution = .fill
        container.axis = .horizontal
        container.alignment = .bottom
        container.spacing = 1.0
        container.translatesAutoresizingMaskIntoConstraints = false
        addSubview(container)
        self.container = container

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
        container.addArrangedSubview(item)
    }

    func remove(item: EditorTabItem) {
        container.removeArrangedSubview(item)
        item.removeFromSuperview()
    }

}
