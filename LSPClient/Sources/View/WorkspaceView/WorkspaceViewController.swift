//
//  WorkspaceViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewController: UIViewController {

    private weak var tableView: UITableView!
    private var workspaceRootFile: HierarchicalFile!
    private var rowFiles: [WorkspaceFile] = []
    private var foldingDirectories: [URL] = []

    override func loadView() {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UIFont.systemFontSize * 2.5
        tableView.dataSource = self
        tableView.delegate = self
        self.tableView = tableView
        self.view = tableView

        fetchWorkspaceFiles()
    }

}


extension WorkspaceViewController: UITableViewDataSource {

    func fetchWorkspaceFiles() {
        workspaceRootFile = WorkspaceManager.shared.fetchFileHierarchy()
        rowFiles.removeAll()
        shouldShowFiles(workspaceRootFile)
    }

    private func shouldShowFiles(_ target: HierarchicalFile) {
        rowFiles.append(WorkspaceFile(target))

        if !foldingDirectories.contains(target.uri) {
            target.children.forEach({ shouldShowFiles($0) })
        }
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowFiles.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = rowFiles[indexPath.row]
        return file.isDirectory ? workspaceViewDirectoryCell(file) : workspaceViewFileCell(file)
    }


    private func workspaceViewDirectoryCell(_ file: WorkspaceFile) -> WorkspaceViewDirectoryCell {
        if let dirCell = tableView.dequeueReusableCell(withIdentifier: file.uri.absoluteString) as? WorkspaceViewDirectoryCell {
            dirCell.foldIcon.isFold = foldingDirectories.contains(file.uri)
            return dirCell
        } else {
            let dirCell = WorkspaceViewDirectoryCell(file: file)
            dirCell.foldIcon.isFold = foldingDirectories.contains(file.uri)
            dirCell.foldIcon.addTapAction(self, action: #selector(toggleFold(_:)))
            return dirCell
        }
    }


    private func workspaceViewFileCell(_ file: WorkspaceFile) -> WorkspaceViewFileCell {
        if let fileCell = tableView.dequeueReusableCell(withIdentifier: file.uri.absoluteString) as? WorkspaceViewFileCell {
            return fileCell
        } else {
            return WorkspaceViewFileCell(file: file)
        }
    }

}


extension WorkspaceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if let fileCell = tableView.cellForRow(at: indexPath) as? WorkspaceViewFileCell {
            if !fileCell.isFile {
                return
            }
            print("open: \(fileCell.uri)")

        } else if let dirCell = tableView.cellForRow(at: indexPath) as? WorkspaceViewDirectoryCell {
            print("select dir: \(dirCell.uri)")

        } else {
            fatalError()
        }
    }

    @objc func toggleFold(_ sender: UIGestureRecognizer) {
        guard let foldIcon = sender.view as? WorkspaceFoldIcon,
                let targetUri = (foldIcon.superview?.superview as? WorkspaceViewDirectoryCell)?.uri else {
            fatalError()
        }

        // Toggle fold flag
        foldIcon.isFold.toggle()

        if foldIcon.isFold {
            // Get target IndexPath
            let paths = indexPaths(targetUri)

            // Remove data source
            foldingDirectories.append(targetUri)
            foldingDirectories.sort(by: localizedStandardOrder)
            rowFiles.removeAll(where: { $0.uri != targetUri && $0.uri.hasPrefix(targetUri) })

            // Delete table row
            tableView.beginUpdates()
            tableView.deleteRows(at: paths, with: .automatic)
            tableView.endUpdates()

        } else {
            // Refresh data source
            foldingDirectories.removeAll(where: { $0 == targetUri })
            rowFiles.removeAll()
            shouldShowFiles(workspaceRootFile)

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
