//
//  CompletionViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewController: UIViewController {
    private(set) weak var completionView: CompletionView!
    private var viewModel: CompletionViewModel!
    private var documentationText: DocumentationText!

    static let rowHeight: CGFloat = UIFont.systemFontSize * 1.4

    var completionRange: NSRange = .notFound
    var filterText: String {
        get {
            self.initialFilterText.appending(self.inputText)
        }
        set {
            self.initialFilterText = newValue
            self.inputText = ""
        }
    }
    private var initialFilterText: String = ""
    private var inputText: String = ""

    var selectedItem: CompletionItem {
        guard let indexPath = self.completionView.itemList.indexPathForSelectedRow else {
            fatalError()
        }
        return self.viewModel.completionItem(at: indexPath)
    }

    override func loadView() {
        // Initialize view model
        let viewModel = CompletionViewModel()
        viewModel.controller = self
        self.viewModel = viewModel

        // Initialize view
        let completionView = CompletionView(frame: CGRect(origin: .zero, size: viewSize))
        completionView.isHidden = true
        completionView.itemList.delegate = self
        completionView.itemList.dataSource = viewModel
        self.completionView = completionView
        self.view = completionView

        //
        refreshCodeStyle()
    }

    override func viewDidLoad() {
        // NotificationCenter
        NotificationCenter.default.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)

        // Table view cell reuse
        CompletionItemKind.allCases.map({ CompletionViewCellIdentifier(kind: $0).string }).forEach() {
            completionView.itemList.register(CompletionViewCell.self, forCellReuseIdentifier: $0)
        }
    }

    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()

        viewModel.set(codeStyle)
        completionView.set(codeStyle)
        documentationText = DocumentationText(codeStyle: codeStyle)
    }

}

extension CompletionViewController: FloatingViewType {

    typealias LSPResultType = CompletionList

    func willShow(_ result: CompletionList) -> Bool {
        // Initialize data source
        viewModel.set(result.items)
        viewModel.update(filterText: initialFilterText)

        // Initialize table view
        if viewModel.tableView(completionView.itemList, numberOfRowsInSection: .zero) > .zero {
            completionView.itemList.reloadData()
            select(row: .zero, scroll: .top)
            return true
        } else {
            return false
        }
    }

}

extension CompletionViewController: UITableViewDelegate {

    @objc func tapItem(sender: UIGestureRecognizer) {
        guard let cell = sender.view as? CompletionViewCell,
                let indexPath = completionView.itemList.indexPath(for: cell),
                let editor = parent as? EditorViewController else {
            fatalError()
        }

        // Select and commit item
        select(row: indexPath.row, scroll: .none)
        editor.commitCompletion()
    }

    private func select(row: Int, scroll: UITableView.ScrollPosition) {
        // Select table cell
        let indexPath = IndexPath(row: row, section: .zero)
        completionView.itemList.selectRow(at: indexPath, animated: false, scrollPosition: scroll)

        // Invoke delegate
        tableView(completionView.itemList, didSelectRowAt: indexPath)
    }

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // Create documentation text
        let selectItem = viewModel.completionItem(at: indexPath)
        let signature = selectItem.label
        let description = selectItem.documentation?.string
        let documentation = documentationText.create(signature: signature, description: description, parameters: nil)

        // Set documentation text
        completionView.documentation.contentOffset = .zero
        completionView.documentation.attributedText = documentation
    }

}

extension CompletionViewController {

    func moveSelection(direction: (Int, Int) -> Int) {
        guard let selected = completionView.itemList.indexPathForSelectedRow else {
            fatalError()
        }

        let row = direction(selected.row, 1)
        let count = viewModel.tableView(completionView.itemList, numberOfRowsInSection: .zero)

        if row < .zero {
            select(row: count - 1, scroll: .middle)
        } else if count <= row {
            select(row: .zero, scroll: .middle)
        } else {
            select(row: row, scroll: .middle)
        }
    }

    func willInput(range: NSRange, text: String) {
        guard completionRange.lowerBound <= range.lowerBound,
                let selectedRow = completionView.itemList.indexPathForSelectedRow else {
            return
        }

        let selectedItem = viewModel.completionItem(at: selectedRow)

        let changeRange = NSMakeRange(range.location - completionRange.location, range.length)
        inputText.replaceSubrange(changeRange, with: text)
        completionRange.length = inputText.length

        // Refresh completion item list
        UIView.performWithoutAnimation {
            let result = viewModel.update(filterText: filterText)
            completionView.itemList.beginUpdates()
            completionView.itemList.deleteRows(at: result.delete, with: .none)
            completionView.itemList.insertRows(at: result.insert, with: .none)
            completionView.itemList.endUpdates()
        }

        // Reload visible rows
        if let reloadRows = completionView.itemList.indexPathsForVisibleRows {
            completionView.itemList.reloadRows(at: reloadRows, with: .none)
        }

        if viewModel.tableView(completionView.itemList, numberOfRowsInSection: .zero) == .zero {
            hide()
        } else if let indexPath = viewModel.indexPath(for: selectedItem) {
            select(row: indexPath.row, scroll: .middle)
        } else {
            select(row: .zero, scroll: .middle)
        }
    }

}




extension CompletionItem.Documentation {

    var string: String? {
        switch self {
        case .string(let text):
            return text
        case .markup(let content):
            return content.kind == .plaintext ? content.value : nil
        }
    }

}
