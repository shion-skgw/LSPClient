//
//  WorkspaceViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewController: UIViewController {

    var workspaceRootFile: HierarchicalFile!
    var workspaceFiles: [WorkspaceFile] = []
    var foldingDirectories: [URL] = [
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

    struct HierarchicalFile {
        let uri: DocumentUri
        let level: Int
        let isDirectory: Bool
        let isLink: Bool
        let isHidden: Bool
        var children: [HierarchicalFile] = []

        init(uri: DocumentUri, level: Int) {
            self.uri = uri
            self.level = level
            self.isDirectory = true
            self.isLink = false
            self.isHidden = false
        }

        init(file: WorkspaceFile) {
            self.uri = file.uri
            self.level = file.level
            self.isDirectory = file.type == .directory
            self.isLink = file.type == .link
            self.isHidden = file.isHidden
        }
    }


    func aaa() {
        workspaceRootFile = HierarchicalFile(uri: WorkspaceManager.shared.workspaceRootUri, level: 0)
        for target in WorkspaceManager.shared.fetchWorkspaceFiles() {
            hierarchicalFile(&workspaceRootFile, target)
        }
        workspaceFiles.removeAll()
        workspaceFiles(&workspaceFiles, workspaceRootFile)
    }


    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return workspaceFiles.count
    }


    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let tableViewCell = UITableViewCell()
        let file = workspaceFiles[indexPath.row]
        tableViewCell.textLabel?.text = "\(Array(repeating: "+", count: file.level).joined())\(file.type == .directory ? "D" : "F") \(file.uri.lastPathComponent)"
        return tableViewCell
    }


    private func hierarchicalFile(_ hierarchical: inout HierarchicalFile, _ target: WorkspaceFile) {
        // Get path components
        let currentComponents = hierarchical.uri.pathComponents
        let targetComponents = target.uri.pathComponents

        if currentComponents.count < targetComponents.count - 1 {
            let childUri = hierarchical.uri.appendingPathComponent(targetComponents[currentComponents.count], isDirectory: true)
            let level = target.level - (targetComponents.count - childUri.pathComponents.count)
            if hierarchical.children.last?.uri != childUri {
                hierarchical.children.append(HierarchicalFile(uri: childUri, level: level))
            }
            hierarchicalFile(&hierarchical.children[hierarchical.children.count - 1], target)

        } else if currentComponents.count == targetComponents.count - 1 {
            hierarchical.children.append(HierarchicalFile(file: target))
        }
    }


    private func workspaceFiles(_ fileArray: inout [WorkspaceFile], _ target: HierarchicalFile) {
        fileArray.append(workspaceFile(target))

        if foldingDirectories.contains(target.uri) {
            return
        }

        for child in target.children {
            workspaceFiles(&fileArray, child)
        }
    }

    private func workspaceFile(_ file: HierarchicalFile) -> WorkspaceFile {
        let fileType: WorkspaceFile.FileType = file.isDirectory ? .directory : file.isLink ? .link : .file
        return WorkspaceFile(uri: file.uri, level: file.level, type: fileType, isHidden: file.isHidden)
    }

}


extension WorkspaceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let cell = tableView.cellForRow(at: indexPath) else {
            return
        }

    }

}
