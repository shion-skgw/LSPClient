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

    private weak var menuView: WorkspaceMenuView!
    private weak var workspaceView: UITableView!

    private let fileSizeAlertThreshold = 1024 * 512
    private let fileSizeLimit = 1024 * 1024
    private let appearance = WorkspaceAppearance.self

    override func viewDidLoad() {
        super.viewDidLoad()

        let menuView = WorkspaceMenuView()
        menuView.backgroundColor = appearance.menuViewColor
        menuView.closeButton.addAction(UIAction(handler: { _ in self.closeView() }), for: .touchUpInside)
        view.addSubview(menuView)
        self.menuView = menuView

        let workspaceView = UITableView()
        workspaceView.rowHeight = appearance.cellHeight
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
        menuViewFrame.size.height = appearance.menuViewSize.height
        menuView.frame = menuViewFrame

        var workspaceViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        workspaceViewFrame.origin.y += menuViewFrame.height
        workspaceViewFrame.size.height -= menuViewFrame.height
        workspaceView.frame = workspaceViewFrame
    }

    func closeView() {
        guard let rootController = parent as? RootViewController else {
            fatalError()
        }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
        rootController.didCloseWorkspace()
    }

}


// MARK: - Workspace menu

extension WorkspaceViewController {

}


// MARK: - Table data source

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

}


// MARK: - Create cell

extension WorkspaceViewController {

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


// MARK: - File open

extension WorkspaceViewController: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let tableCell = workspaceView.cellForRow(at: indexPath) as? WorkspaceViewCell,
                let file = workspaceFiles.filter({ tableCell.uri == $0.uri }).first else {
            fatalError()
        }

        if WorkspaceManager.shared.exists(uri: file.uri) {
            openDocument(file)

        } else if file.size > fileSizeLimit {
            let alert = UIAlertController.anyAlert(title: "aaa", message: "Huge")
            present(alert, animated: true)

        } else if file.size > fileSizeAlertThreshold {
            let alert = UIAlertController.largeFile(size: file.size, limit: fileSizeAlertThreshold) {
                [weak self, file] in
                self?.openDocumentWithClone(file)
            }
            present(alert, animated: true)

        } else {
            openDocumentWithClone(file)
        }
    }

    private func openDocumentWithClone(_ file: WorkspaceFile) {
        do {
            try WorkspaceManager.shared.clone(uri: file.uri)
            _ = try WorkspaceManager.shared.open(uri: file.uri)
            openDocument(file)

        } catch WorkspaceError.fileNotFound {
            let alert = UIAlertController.fileNotFound(uri: file.uri)
            present(alert, animated: true)

        } catch WorkspaceError.encodingFailure {
            try? WorkspaceManager.shared.remove(uri: file.uri)
            let alert = UIAlertController.unsupportedFile(uri: file.uri)
            present(alert, animated: true)

        } catch {
            let alert = UIAlertController.anyAlert(title: "aaa", message: error.localizedDescription)
            present(alert, animated: true)
        }
    }

    private func openDocument(_ file: WorkspaceFile) {
        guard let rootController = parent as? RootViewController else {
            fatalError()
        }
        rootController.willOpenDocument(file.uri)
    }

}


// MARK: - Directory fold

extension WorkspaceViewController {

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
