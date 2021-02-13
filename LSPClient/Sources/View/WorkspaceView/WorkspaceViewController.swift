//
//  WorkspaceViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewController: UIViewController {

    private var workspaceFiles: [WorkspaceFile] = []
    private var displayFiles: [WorkspaceFile] = []
    private var foldDirectories: [DocumentUri] = []

    private(set) weak var menuView: WorkspaceMenuView!
    private(set) weak var workspaceView: UITableView!

    override func viewDidLoad() {
        super.viewDidLoad()

        let menuView = WorkspaceMenuView()
        menuView.closeButton.addAction(closeWorkspace, for: .touchUpInside)
        menuView.backgroundColor = .secondarySystemBackground
        view.addSubview(menuView)
        self.menuView = menuView

        let workspaceView = UITableView()
        workspaceView.rowHeight = UIFont.systemFontSize * 2.5
        workspaceView.estimatedRowHeight = 0
        workspaceView.separatorStyle = .none
        workspaceView.dataSource = self
        workspaceView.delegate = self
        view.addSubview(workspaceView)
        self.workspaceView = workspaceView

        if workspaceFiles.isEmpty {
            fetchWorkspaceFiles()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var menuViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        menuViewFrame.size.height = 30.0
        menuView.frame = menuViewFrame

        var workspaceViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        workspaceViewFrame.origin.y += menuViewFrame.height
        workspaceViewFrame.size.height -= menuViewFrame.height
        workspaceView.frame = workspaceViewFrame
    }

}


// MARK: - Workspace menu

extension WorkspaceViewController {

    private func closeWorkspace(_: UIAction) {
        guard let rootController = parent as? RootViewController else {
            fatalError()
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        rootController.didCloseWorkspace()
    }

}


// MARK: - UITableViewDataSource

extension WorkspaceViewController: UITableViewDataSource {

    func fetchWorkspaceFiles() {
        self.workspaceFiles = WorkspaceManager.shared.fetchRemoteWorkspaceFiles(skipsHidden: false)

        self.displayFiles = workspaceFiles.filter(shouldShowFile)

        for file in workspaceFiles {
            let identifier = WorkspaceViewCellIdentifier(file).string
            workspaceView.register(WorkspaceViewCell.self, forCellReuseIdentifier: identifier)
        }
    }

    private func shouldShowFile(_ file: WorkspaceFile) -> Bool {
        return !foldDirectories.contains(where: { file.uri != $0 && file.uri.hasPrefix($0) })
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayFiles.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = displayFiles[indexPath.row]
        let identifier = WorkspaceViewCellIdentifier(file).string

        guard let tableCell = workspaceView.dequeueReusableCell(withIdentifier: identifier, for: indexPath) as? WorkspaceViewCell else {
            fatalError()
        }

        tableCell.uri = file.uri

        if let foldButton = tableCell.foldButton {
            foldButton.isFold = foldDirectories.contains(file.uri)
            if !foldButton.allTargets.contains(where: { $0 is WorkspaceViewController }) {
                foldButton.addTarget(self, action: #selector(toggleFold(_:)), for: .touchUpInside)
            }
        }

        return tableCell
    }

}


// MARK: - UITableViewDelegate

extension WorkspaceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableCell = workspaceView.cellForRow(at: indexPath) as? WorkspaceViewCell,
                let file = workspaceFiles.filter({ tableCell.uri == $0.uri }).first else {
            fatalError()
        }

        if file.size < 1000 {
            NotificationCenter.default.post(name: .willOpenDocument, object: nil, userInfoValue: file.uri)

        } else {
            let alert = UIAlertController(title: "Huge file", message: "Open?", preferredStyle: .alert)
            let open = UIAlertAction(title: "Open", style: .default) {
                [file] action in
                NotificationCenter.default.post(name: .willOpenDocument, object: nil, userInfoValue: file.uri)
            }
            let cancel = UIAlertAction(title: "Cancel", style: .cancel)
            alert.addAction(open)
            alert.addAction(cancel)
            present(alert, animated: true)
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
            foldDirectories.sort(by: { $0.path.localizedStandardCompare($1.path) == .orderedAscending })
            displayFiles.removeAll(where: { $0.uri != targetUri && $0.uri.hasPrefix(targetUri) })

            // Delete table row
            workspaceView.beginUpdates()
            workspaceView.deleteRows(at: paths, with: .fade)
            workspaceView.endUpdates()

        } else {
            // Refresh data source
            foldDirectories.removeAll(where: { $0 == targetUri })
            displayFiles = workspaceFiles.filter(shouldShowFile)

            // Get target IndexPath
            let paths = indexPaths(targetUri)

            // Insert table row
            workspaceView.beginUpdates()
            workspaceView.insertRows(at: paths, with: .fade)
            workspaceView.endUpdates()
        }
    }

    private func indexPaths(_ uri: DocumentUri) -> [IndexPath] {
        var startIndex = Int.zero
        var endIndex = Int.zero

        for index in displayFiles.startIndex ..< displayFiles.endIndex {
            if displayFiles[index].uri == uri {
                startIndex = index + 1

            } else if displayFiles[index].uri.hasPrefix(uri) {
                endIndex = index

            } else if startIndex != .zero {
                break
            }
        }

        if endIndex == .zero {
            return []
        } else {
            return (startIndex...endIndex).compactMap({ IndexPath(row: $0, section: 0) })
        }
    }

}
