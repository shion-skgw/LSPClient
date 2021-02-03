//
//  WorkspaceViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewController: UIViewController {

    private var workspaceRootFile: HierarchicalFile!
    private var rowFiles: [File] = []
    private var foldingDirectories: [URL] = [
//        URL(string: "file:///Users/shion/Documents/Eclipse/")!
    ]

    override func loadView() {
        let tableView = UITableView()
        tableView.dataSource = self
        tableView.delegate = self
        self.view = tableView

        aaa()
    }

}


extension WorkspaceViewController: UITableViewDataSource {

    private struct File {
        let uri: DocumentUri
        let level: Int
        let isDirectory: Bool
        let isLink: Bool
        let isHidden: Bool

        init(_ file: HierarchicalFile) {
            self.uri = file.uri
            self.level = file.level
            self.isDirectory = file.isDirectory
            self.isLink = file.isLink
            self.isHidden = file.isHidden
        }
    }


    func aaa() {
        workspaceRootFile = WorkspaceManager.shared.fetchFileHierarchy()
        rowFiles.removeAll()
        shouldShowFiles(workspaceRootFile)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowFiles.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()
        let file = rowFiles[indexPath.row]
        tableViewCell.textLabel?.text = "\(Array(repeating: "+", count: file.level).joined())\(file.isDirectory ? "D" : "F") \(file.uri.lastPathComponent)"
        return tableViewCell
    }


    private func shouldShowFiles(_ target: HierarchicalFile) {
        rowFiles.append(File(target))

        if !foldingDirectories.contains(target.uri) {
            target.children.forEach({ shouldShowFiles($0) })
        }
    }

}


extension WorkspaceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

    }

}
