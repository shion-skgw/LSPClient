//
//  CompletionViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewController: UIViewController {

    private(set) weak var itemListView: UITableView!
    private(set) weak var separatorView: UIView!
    private(set) weak var detailView: CompletionDetailView!

    var completionItems: [CompletionItem] = []
    private let borderWidth: CGFloat = 0.5

    override func viewDidLoad() {
        self.view.layer.borderWidth = borderWidth
        self.view.layer.cornerRadius = 3

        let itemListView = UITableView()
        itemListView.delegate = self
        itemListView.dataSource = self
        itemListView.separatorStyle = .none
        itemListView.estimatedRowHeight = .zero
        itemListView.tableFooterView = detailView
        view.addSubview(itemListView)
        self.itemListView = itemListView

        let separatorView = UIView()
        view.addSubview(separatorView)
        self.separatorView = separatorView

        let detailView = CompletionDetailView()
        view.addSubview(detailView)
        self.detailView = detailView

        CompletionItemKind.allCases.map({ CompletionViewCellIdentifier(kind: $0) }).forEach() {
            itemListView.register(CompletionViewCell.self, forCellReuseIdentifier: $0.string)
        }
        changeCodeStyle()
    }

    override func viewDidLayoutSubviews() {
        var itemListViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        itemListViewFrame.size.height -= itemListViewFrame.height / 2
        itemListView.frame = itemListViewFrame

        var separatorViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        separatorViewFrame.origin.y = itemListViewFrame.maxY
        separatorViewFrame.size.height = borderWidth
        separatorView.frame = separatorViewFrame

        var detailViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        detailViewFrame.origin.y = separatorViewFrame.maxY
        detailViewFrame.size.height -= separatorViewFrame.maxY
        detailView.frame = detailViewFrame
    }

    private func changeCodeStyle() {
        // Load code style
        let codeStyle = CodeStyle.load()

        separatorView.backgroundColor = codeStyle.edgeColor
        self.view.layer.borderColor = codeStyle.edgeColor.cgColor

        // Update item list view
        itemListView.rowHeight = codeStyle.font.size * 1.4
        itemListView.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white
        itemListView.backgroundColor = codeStyle.backgroundColor

        detailView.set(codeStyle: codeStyle)
    }

    func didInputArrow(input: String) {
        switch input {
        case UIKeyCommand.inputUpArrow:
            moveSelectRow(-)
        case UIKeyCommand.inputDownArrow:
            moveSelectRow(+)
        default:
            fatalError()
        }
    }

    private func moveSelectRow(_ direction: (Int, Int) -> Int) {
        guard let current = itemListView.indexPathForSelectedRow?.row else {
            let index = IndexPath(row: .zero, section: .zero)
            itemListView.selectRow(at: index, animated: false, scrollPosition: .top)
            return
        }

        var selectRow = direction(current, 1)
        if selectRow < .zero {
            selectRow = completionItems.count - 1
        } else if completionItems.count <= selectRow {
            selectRow = .zero
        }

        let index = IndexPath(row: selectRow, section: .zero)
        itemListView.selectRow(at: index, animated: false, scrollPosition: .middle)
        self.tableView(itemListView, didSelectRowAt: index)
    }

}

extension CompletionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_: UITableView, numberOfRowsInSection section: Int) -> Int {
        return completionItems.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let completionItem = completionItems[indexPath.row]
        let identifier = CompletionViewCellIdentifier(kind: completionItem.kind)
        guard let tableCell = itemListView.dequeueReusableCell(withIdentifier: identifier.string, for: indexPath) as? CompletionViewCell else {
            fatalError()
        }
        let label = completionItem.label
        let deprecated = completionItem.deprecated ?? completionItem.tags?.contains(.deprecated) ?? false
        tableCell.set(codeStyle: CodeStyle.load())
        tableCell.set(label: label, deprecated: deprecated)
        return tableCell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let completionItem = completionItems[indexPath.row]
        let label = completionItem.label
        let deprecated = completionItem.deprecated ?? completionItem.tags?.contains(.deprecated) ?? false
        let detail = completionItem.documentation?.string.replacing(of: "(\r\n|\r|\n)+", with: "\n") ?? ""
        detailView.set(label: label, deprecated: deprecated, detail: detail)
    }

}

extension CompletionItem.Documentation {

    var string: String {
        switch self {
        case .string(let text):
            return text
        case .markup(let content):
            return content.kind == .plaintext ? content.value : ""
        }
    }

}
