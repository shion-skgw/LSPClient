//
//  WorkspaceViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewController: UITableViewController {

    private var workspaceRootFile: HierarchicalFile!
    private var rowFiles: [WorkspaceFile] = []
    private var foldDirectories: [URL] = []

    override func loadView() {
        let tableView = UITableView()
        tableView.rowHeight = UIFont.systemFontSize * 2.5
        tableView.estimatedRowHeight = 0
        tableView.separatorStyle = .none
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView = tableView

        fetchWorkspaceFiles()
    }

}


// MARK: - UITableViewDataSource

extension WorkspaceViewController {

    func fetchWorkspaceFiles() {
        self.workspaceRootFile = WorkspaceManager.shared.fetchFileHierarchy()

        let files = workspaceFiles(self.workspaceRootFile)

        self.rowFiles = files.filter(shouldShowFile)

        for file in files {
            tableView.register(WorkspaceViewCell.self, forCellReuseIdentifier: file.cellReuseIdentifier)
        }
    }

    private func workspaceFiles(_ target: HierarchicalFile) -> [WorkspaceFile] {
        var files: [WorkspaceFile] = [WorkspaceFile(file: target)]
        target.children.forEach({ files.append(contentsOf: workspaceFiles($0)) })
        return files
    }

    private func shouldShowFile(_ file: WorkspaceFile) -> Bool {
        return !foldDirectories.contains(where: { file.uri != $0 && file.uri.hasPrefix($0) })
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowFiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = rowFiles[indexPath.row]
        let identifier = file.cellReuseIdentifier

        guard let cell = tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? WorkspaceViewCell else {
            fatalError()
        }

        cell.uri = file.uri
        cell.nameLabel.text = file.uri.lastPathComponent
        cell.foldButton?.isFold = foldDirectories.contains(file.uri)
        cell.foldButton?.addTarget(self, action: #selector(toggleFold(_:)), for: .touchUpInside)
        return cell
    }

}


// MARK: - UITableViewDelegate

extension WorkspaceViewController {

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) as? WorkspaceViewCell else {
            fatalError()
        }
    }

    @objc func toggleFold(_ sender: WorkspaceFoldButton) {
        guard let targetUri = (sender.superview?.superview as? WorkspaceViewCell)?.uri else {
            fatalError()
        }

        // Toggle fold flag
        sender.isFold.toggle()

        if sender.isFold {
            // Get target IndexPath
            let paths = indexPaths(targetUri)

            // Remove data source
            foldDirectories.append(targetUri)
            foldDirectories.sort(by: localizedStandardOrder)
            rowFiles.removeAll(where: { $0.uri != targetUri && $0.uri.hasPrefix(targetUri) })

            // Delete table row
            tableView.beginUpdates()
            tableView.deleteRows(at: paths, with: .automatic)
            tableView.endUpdates()

        } else {
            // Refresh data source
            foldDirectories.removeAll(where: { $0 == targetUri })
            rowFiles = workspaceFiles(self.workspaceRootFile).filter(shouldShowFile)

            // Get target IndexPath
            let paths = indexPaths(targetUri)

            // Insert table row
            tableView.beginUpdates()
            tableView.insertRows(at: paths, with: .automatic)
            tableView.endUpdates()
        }
    }

    private func indexPaths(_ uri: DocumentUri) -> [IndexPath] {
        var startIndex = 0
        var endIndex = 0

        for index in rowFiles.startIndex ..< rowFiles.endIndex {
            if rowFiles[index].uri == uri {
                startIndex = index + 1
                endIndex = startIndex
            } else if rowFiles[index].uri.hasPrefix(uri) {
                endIndex = index
            }
        }

        return (startIndex...endIndex).compactMap({ IndexPath(row: $0, section: 0) })
    }

}
