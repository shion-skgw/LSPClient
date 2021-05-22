//
//  CompletionViewCellIdentifier.swift
//  LSPClient
//
//  Created by Shion on 2021/05/09.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

struct CompletionViewCellIdentifier {
    let kind: CompletionItemKind?

    var string: String {
        return String(self.kind?.rawValue ?? 0)
    }

    init(kind: CompletionItemKind?) {
        self.kind = kind
    }

    init?(identifier: String) {
        guard let a = Int(identifier) else {
            fatalError()
        }
        self.kind = CompletionItemKind(rawValue: a)
    }

    func icon(size: CGFloat, weight: UIImage.SymbolWeight) -> UIImage {
        let config = UIImage.SymbolConfiguration(pointSize: size, weight: weight)
        return UIImage(systemName: "a.circle.fill", withConfiguration: config)!
    }

    var iconColor: UIColor {
        return .blue
    }

}
