//
//  CompletionViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/05/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class CompletionViewController: UIViewController {
    var data: CompletionList?
    override func loadView() {
        let view = UITableView(frame: .zero, style: .plain)
        view.frame = CGRect(x: 10, y: 10, width: 150, height: 100)
        view.rowHeight = 30
        view.dataSource = self
        self.view = view
    }
}

extension CompletionViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return data?.items.count ?? .zero
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell()
        cell.textLabel?.frame = CGRect(x: 0, y: 0, width: 140, height: 30)
        cell.textLabel?.text = data?.items[indexPath.row].label ?? "---"
        print("================================== \(cell.textLabel?.text)")
        return cell
    }

}
