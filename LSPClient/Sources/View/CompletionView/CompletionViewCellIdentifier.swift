//
//  CompletionViewCellIdentifier.swift
//  LSPClient
//
//  Created by Shion on 2021/05/09.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

struct CompletionViewCellIdentifier {
    let kind: CompletionItemKind

    var string: String {
        return String(self.kind.rawValue)
    }

    init(kind: CompletionItemKind) {
        self.kind = kind
    }

    init?(identifier: String) {
        guard let a = Int(identifier), let b = CompletionItemKind(rawValue: a) else {
            fatalError()
        }
        self.kind = b
    }

    func icon(config: UIImage.SymbolConfiguration) -> UIImage {
        return UIImage(systemName: "a.circle.fill", withConfiguration: config)!
    }

}
