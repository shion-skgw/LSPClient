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
        tableView.separatorStyle = .none
        tableView.rowHeight = UIFont.systemFontSize * 2.5
        tableView.dataSource = self
        tableView.delegate = self
        self.view = tableView

        fetchWorkspaceFiles()
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


    func fetchWorkspaceFiles() {
        workspaceRootFile = WorkspaceManager.shared.fetchFileHierarchy()
        rowFiles.removeAll()
        shouldShowFiles(workspaceRootFile)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return rowFiles.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = rowFiles[indexPath.row]
        if file.isDirectory {
            let dirCell = WorkspaceViewDirectoryCell(uri: file.uri, isHidden: file.isHidden, level: file.level)
            dirCell.isFold = foldingDirectories.contains(dirCell.uri)
            return dirCell
        } else {
            return WorkspaceViewFileCell(uri: file.uri, isLink: file.isLink, isHidden: file.isHidden, level: file.level)
        }
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
        if let fileCell = tableView.cellForRow(at: indexPath) as? WorkspaceViewFileCell {
            if !fileCell.isFile {
                return
            }
            print("open: \(fileCell.uri)")

        } else if let dirCell = tableView.cellForRow(at: indexPath) as? WorkspaceViewDirectoryCell {
            // Toggle fold flag
            dirCell.isFold.toggle()

            if dirCell.isFold {
                // Get target IndexPath
                let paths = indexPaths(dirCell.uri)

                // Remove data source
                foldingDirectories.append(dirCell.uri)
                foldingDirectories.sort(by: { $0.path.localizedStandardCompare($1.path) == .orderedAscending })
                rowFiles.removeAll(where: { $0.uri != dirCell.uri && $0.uri.absoluteString.hasPrefix(dirCell.uri.absoluteString) })

                // Delete table row
                tableView.beginUpdates()
                tableView.deleteRows(at: paths, with: .automatic)
                tableView.endUpdates()

            } else {
                // Refresh data source
                foldingDirectories.removeAll(where: { $0 == dirCell.uri })
                rowFiles.removeAll()
                shouldShowFiles(workspaceRootFile)

                // Get target IndexPath
                let paths = indexPaths(dirCell.uri)

                // Insert table row
                tableView.beginUpdates()
                tableView.insertRows(at: paths, with: .automatic)
                tableView.endUpdates()
            }

        } else {
            fatalError()
        }
    }

    private func indexPaths(_ uri: DocumentUri) -> [IndexPath] {
        var startIndex = 0
        var endIndex = 0

        for index in rowFiles.startIndex ..< rowFiles.endIndex {
            if rowFiles[index].uri == uri {
                startIndex = index + 1
                endIndex = startIndex
            } else if rowFiles[index].uri.absoluteString.hasPrefix(uri.absoluteString) {
                endIndex = index
            }
        }

        return (startIndex...endIndex).compactMap({ IndexPath(row: $0, section: 0) })
    }

}
