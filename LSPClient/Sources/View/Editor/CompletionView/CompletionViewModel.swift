//
//  CompletionViewModel.swift
//  LSPClient
//
//  Created by Shion on 2021/06/01.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewModel: NSObject, UITableViewDataSource {

    weak var controller: CompletionViewController!
    private var completionItems: [CompletionItem] = []
    private var displayItems: [CompletionItem] = []
    private var codeStyle: CodeStyle!

    func indexPath(for item: CompletionItem) -> IndexPath? {
        guard let index = displayItems.firstIndex(of: item) else {
            return nil
        }
        return IndexPath(row: index, section: .zero)
    }

    func completionItem(at indexPath: IndexPath) -> CompletionItem {
        return displayItems[indexPath.row]
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayItems.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let item = displayItems[indexPath.row]
        let identifier = CompletionViewCellIdentifier(kind: item.kind).string
        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? CompletionViewCell else {
            fatalError()
        }

        if cell.gestureRecognizers?.isEmpty ?? true {
            let gesture = UITapGestureRecognizer(target: controller, action: #selector(controller.tapItem))
            gesture.cancelsTouchesInView = false
            cell.addGestureRecognizer(gesture)
        }

        cell.set(codeStyle)
        cell.label.attributedText = labelText(item)
        return cell
    }

    private func labelText(_ item: CompletionItem) -> NSAttributedString {
        var attributes = NSAttributedString.makeAttributes(font: codeStyle.font.uiFont, color: codeStyle.fontColor.text.uiColor)
        if item.deprecated ?? item.tags?.contains(.deprecated) ?? false {
            attributes.merge(NSAttributedString.makeStrikeThrough(style: .single), uniquingKeysWith: { $1 })
        }
        return NSAttributedString(string: item.label, attributes: attributes)
    }

    @discardableResult func update(filterText: String) -> (delete: [IndexPath], insert: [IndexPath]) {
        // Search condition
        let text = filterText.lowercased()
        let contains: (CompletionItem) -> Bool = {
            return text.isEmpty
                || $0.filterText?.lowercased().contains(text)
                ?? $0.insertText?.lowercased().contains(text)
                ?? $0.label.lowercased().contains(text)
        }

        // Before and after items
        let beforeItems = displayItems
        displayItems = completionItems.filter(contains)

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
        return (deleteRows, insertRows)
    }

    func set(_ codeStyle: CodeStyle) {
        self.codeStyle = codeStyle
    }

    func set(_ completionItems: [CompletionItem]) {
        self.completionItems = completionItems.sorted(by: <)
    }

    func append(_ completionItems: [CompletionItem]) {
        self.completionItems.append(contentsOf: completionItems.sorted(by: <))
    }

}

extension CompletionItem: Comparable {

    static func < (lhs: CompletionItem, rhs: CompletionItem) -> Bool {
        if lhs.preselect ?? false == rhs.preselect ?? false {
            let l = lhs.sortText ?? lhs.insertText ?? lhs.label
            let r = rhs.sortText ?? rhs.insertText ?? rhs.label
            return l.localizedStandardCompare(r) == .orderedAscending
        } else {
            return lhs.preselect ?? false
        }
    }

    static func == (lhs: CompletionItem, rhs: CompletionItem) -> Bool {
        return "\(lhs)" == "\(rhs)"
    }

}
