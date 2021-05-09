//
//  CompletionViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewController: UIViewController {

    private(set) weak var tableView: UITableView!
    private(set) weak var footerView: UIView!

    var data: CompletionList?

    override func loadView() {
        let view = UITableView(frame: .zero, style: .plain)
        view.frame = CGRect(x: 10, y: 10, width: 150, height: 100)
        view.rowHeight = CodeStyle.load().font.size * 1.4
        view.dataSource = self
        self.view = view
    }

    override func viewDidLoad() {
        CompletionItemKind.allCases.map({ CompletionViewCellIdentifier(kind: $0) }).forEach() {
            tableView?.register(CompletionViewCell.self, forCellReuseIdentifier: $0.string)
        }
    }

}

extension CompletionViewController: UITableViewDataSource {

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.items.count ?? .zero
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let identifier = CompletionViewCellIdentifier(kind: data?.items[indexPath.row].kind ?? .class)
        guard let tableCell = tableView.dequeueReusableCell(withIdentifier: identifier.string, for: indexPath) as? CompletionViewCell else {
            fatalError()
        }
        tableCell.textLabel?.text = data?.items[indexPath.row].label ?? "---"
        tableCell.textLabel?.font = CodeStyle.load().font.uiFont
        let config = UIImage.SymbolConfiguration(pointSize: CodeStyle.load().font.size, weight: .thin)
        tableCell.imageView?.image = UIImage(systemName: "f.circle.fill", withConfiguration: config)
        return tableCell
    }

}
