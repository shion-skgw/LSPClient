//
//  CompletionViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewController: UIViewController {
    /// Completion items view
    private(set) weak var itemsView: UITableView!
    /// Separator view
    private(set) weak var separatorView: UIView!
    /// Completion detail view
    private(set) weak var detailView: CompletionDetailView!

    private let viewSize: CGSize = CGSize(width: 260, height: 180)
    private let borderWidth: CGFloat = 0.5
    private let cornerRadius: CGFloat = 3
    private var codeStyle: CodeStyle = CodeStyle.load()

    var completionRange: NSRange = .zero
    private var inputText: String = ""
    private var initialFilterText: String = ""
    private var completionItems: [CompletionItem] = []
    private var displayItems: [CompletionItem] = []

    var filterText: String {
        get {
            self.initialFilterText.appending(self.inputText)
        }
        set {
            self.initialFilterText = newValue
            self.inputText = ""
        }
    }

    var selectedItem: CompletionItem {
        guard let row = itemsView.indexPathForSelectedRow?.row else {
            fatalError()
        }
        return displayItems[row]
    }

    override func loadView() {
        let view = UIView(frame: CGRect(origin: .zero, size: viewSize))
        view.isHidden = true
        view.layer.borderWidth = borderWidth
        view.layer.cornerRadius = cornerRadius
        self.view = view

        let itemsView = createItemsView()
        self.view.addSubview(itemsView)
        self.itemsView = itemsView

        let separatorView = createSeparatorView(itemsView.frame)
        self.view.addSubview(separatorView)
        self.separatorView = separatorView

        let detailView = createDetailView(separatorView.frame)
        self.view.addSubview(detailView)
        self.detailView = detailView

        changeCodeStyle()
    }

    private func createItemsView() -> UITableView {
        var itemsViewFrame = CGRect(origin: .zero, size: viewSize)
        itemsViewFrame.size.height = itemsViewFrame.height / 2

        let itemsView = UITableView(frame: itemsViewFrame, style: .plain)
        itemsView.delegate = self
        itemsView.dataSource = self
        itemsView.separatorStyle = .none
        itemsView.estimatedRowHeight = .zero
        return itemsView
    }

    private func createSeparatorView(_ itemsViewFrame: CGRect) -> UIView {
        var separatorViewFrame = CGRect(origin: .zero, size: viewSize)
        separatorViewFrame.origin.y = itemsViewFrame.maxY
        separatorViewFrame.size.height = borderWidth

        return UIView(frame: separatorViewFrame)
    }

    private func createDetailView(_ separatorViewFrame: CGRect) -> CompletionDetailView {
        var detailViewFrame = CGRect(origin: .zero, size: viewSize)
        detailViewFrame.origin.y = separatorViewFrame.maxY
        detailViewFrame.size.height -= separatorViewFrame.maxY

        return CompletionDetailView(frame: detailViewFrame)
    }

    override func viewDidLoad() {
        NotificationCenter.default.addObserver(self, selector: #selector(changeCodeStyle), name: .didChangeCodeStyle, object: nil)
        CompletionItemKind.allCases.map({ CompletionViewCellIdentifier(kind: $0) }).forEach() {
            itemsView.register(CompletionViewCell.self, forCellReuseIdentifier: $0.string)
        }
    }

    @objc private func changeCodeStyle() {
        // Load code style
        codeStyle = CodeStyle.load()

        // Update view border
        view.layer.borderColor = codeStyle.edgeColor.cgColor

        // Update completion items view
        itemsView.rowHeight = codeStyle.font.size * 1.4
        itemsView.indicatorStyle = codeStyle.backgroundColor.isBright ? .black : .white
        itemsView.backgroundColor = codeStyle.backgroundColor

        // Update separator view
        separatorView.backgroundColor = codeStyle.edgeColor

        // Update completion detail view
        detailView.set(codeStyle: codeStyle)
    }

}


// MARK: - UITableViewDataSource, UITableViewDelegate

extension CompletionViewController: UITableViewDataSource, UITableViewDelegate {

    func tableView(_: UITableView, numberOfRowsInSection _: Int) -> Int {
        return displayItems.count
    }

    func tableView(_: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayItems[indexPath.row]
        let identifier = CompletionViewCellIdentifier(kind: item.kind)
        guard let tableCell = itemsView.dequeueReusableCell(withIdentifier: identifier.string, for: indexPath) as? CompletionViewCell else {
            fatalError()
        }
        let label = item.label
        let deprecated = item.deprecated ?? item.tags?.contains(.deprecated) ?? false
        tableCell.set(codeStyle: codeStyle)
        tableCell.set(label: label, deprecated: deprecated)
        return tableCell
    }

    func tableView(_: UITableView, didSelectRowAt indexPath: IndexPath) {
        let item = displayItems[indexPath.row]
        let label = item.label
        let deprecated = item.deprecated ?? item.tags?.contains(.deprecated) ?? false
        let detail = item.documentation?.string.replacing(of: "(\r\n|\r|\n)+", with: "\n").appending("\n\n\n") ?? ""
        detailView.set(label: label, deprecated: deprecated, detail: detail)
    }

}


// MARK: - View display control

extension CompletionViewController {

    func show(items: [CompletionItem], caretRect: CGRect) {
        // Initialize
        completionItems = items.sorted(by: CompletionItem.compare)
        displayItems = completionItems.filter({ $0.hasPrefix(initialFilterText) })

        // Refresh completion table
        itemsView.reloadData()
        selectRow(.zero, .middle)

        // Setting view
        view.frame.origin = viewOrigin(caretRect)
        view.isHidden = false
    }

    private func viewOrigin(_ caretRect: CGRect) -> CGPoint {
        guard let superViewBounds = parent?.view.bounds else {
            fatalError()
        }

        // Calc view frame
        let origin = CGPoint(x: caretRect.minX - 40, y: caretRect.maxY + 4)
        var frame = CGRect(origin: origin, size: view.bounds.size)

        // Correcting X,Y
        if superViewBounds.maxX - 6 < frame.maxX {
            frame.origin.x -= frame.maxX - superViewBounds.maxX + 6
        }
        if superViewBounds.maxY - 6 < frame.maxY {
            frame.origin.y = caretRect.minY - frame.height - 4
        }

        return frame.origin
    }

    func hide() {
        view.isHidden = true
        completionRange = .zero
        filterText = ""
    }

}


// MARK: - List control

extension CompletionViewController {

    func willInput(text: String, range: NSRange) {
        guard !text.isEmpty || completionRange.location <= range.location else {
            return
        }

        // Get selected item
        let selectedItem = self.selectedItem

        // Calc change location
        var location = range.location - completionRange.location
        if text.isEmpty && range.length == .zero {
            location -= 1
        }

        // Update completion status
        let changeRange = Range(NSMakeRange(location, range.length), in: inputText)!
        inputText.replaceSubrange(changeRange, with: text)
        completionRange.length = inputText.length

        // Refresh completion table
        refreshCompletionItems()

        if displayItems.isEmpty {
            hide()
        } else if let row = displayItems.firstIndex(where: { "\($0)" == "\(selectedItem)" }) {
            selectRow(row, .middle)
        } else {
            selectRow(.zero, .middle)
        }
    }

    func moveSelect(direction: (Int, Int) -> Int) {
        guard var row = itemsView.indexPathForSelectedRow?.row else {
            fatalError()
        }

        row = direction(row, 1)

        if row < .zero {
            selectRow(displayItems.count - 1, .middle)
        } else if displayItems.count <= row {
            selectRow(.zero, .middle)
        } else {
            selectRow(row, .middle)
        }
    }

    private func selectRow(_ row: Int, _ position: UITableView.ScrollPosition) {
        let index = IndexPath(row: row, section: .zero)
        itemsView.selectRow(at: index, animated: false, scrollPosition: position)
        tableView(itemsView, didSelectRowAt: index)
    }

    private func refreshCompletionItems() {
        // Before and after items
        let beforeItems = displayItems
        displayItems = completionItems.filter({ $0.hasPrefix(filterText) })

        // Get the difference
        var deleteRows: [IndexPath] = []
        var insertRows: [IndexPath] = []
        displayItems.enumerated().map({ $0.offset }).difference(from: beforeItems.enumerated().map({ $0.offset })).forEach() {
            switch $0 {
            case .remove(let offset, _, _):
                deleteRows.append(IndexPath(row: offset, section: .zero))
            case .insert(let offset, _, _):
                insertRows.append(IndexPath(row: offset, section: .zero))
            }
        }

        // Update completion list
        UIView.performWithoutAnimation {
            itemsView.beginUpdates()
            itemsView.deleteRows(at: deleteRows, with: .none)
            itemsView.insertRows(at: insertRows, with: .none)
            itemsView.endUpdates()
        }

        // Reload visible rows
        if let reloadRows = itemsView.indexPathsForVisibleRows {
            itemsView.reloadRows(at: reloadRows, with: .none)
        }
    }

}

extension CompletionItem {

    static func compare(aItem: CompletionItem, bItem: CompletionItem) -> Bool {
        let aText = aItem.sortText ?? aItem.insertText ?? aItem.label
        let bText = bItem.sortText ?? bItem.insertText ?? bItem.label
        return aText.localizedStandardCompare(bText) == .orderedAscending
    }

    func hasPrefix(_ text: String) -> Bool {
        return insertText?.hasPrefix(text) ?? false
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
