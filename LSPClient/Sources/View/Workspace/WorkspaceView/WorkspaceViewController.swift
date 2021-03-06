//
//  WorkspaceViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/02.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceViewController: UIViewController {
    /// Workspace menu view
    private(set) weak var menuView: WorkspaceMenuView!
    /// Separator view
    private(set) weak var separatorView: UIView!
    /// Workspace view
    private(set) weak var workspaceView: UITableView!

    /// Table row height
    static let rowHeight: CGFloat = UIFont.systemFontSize * 2.5
    /// Workspace menu view height
    private let menuViewHeight: CGFloat = 30
    /// Separator weight
    private let separatorWeight: CGFloat = 0.5

    /// All files in the workspace
    private var workspaceFiles: [WorkspaceFile] = []
    /// Display files
    private var displayFiles: [WorkspaceFile] = []
    /// Fold directories
    private var foldDirectories: [DocumentUri] = []

    override func viewDidLoad() {
        super.viewDidLoad()

        // Workspace menu view
        let menuView = WorkspaceMenuView()
        menuView.backgroundColor = .secondarySystemBackground
        menuView.closeButton.addAction(closeWorkspace, for: .touchUpInside)
        view.addSubview(menuView)
        self.menuView = menuView

        // Separator view
        let separatorView = UIView()
        separatorView.backgroundColor = .opaqueSeparator
        view.addSubview(separatorView)
        self.separatorView = separatorView

        // Workspace view
        let workspaceView = UITableView()
        workspaceView.delegate = self
        workspaceView.dataSource = self
        workspaceView.separatorStyle = .none
        workspaceView.estimatedRowHeight = .zero
        workspaceView.rowHeight = WorkspaceViewController.rowHeight
        view.addSubview(workspaceView)
        self.workspaceView = workspaceView

        // Fetch workspace files
        if workspaceFiles.isEmpty {
            fetchWorkspaceFiles()
        }
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Workspace menu view
        var menuViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        menuViewFrame.size.height = menuViewHeight
        menuView.frame = menuViewFrame

        // Separator view
        var separatorViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        separatorViewFrame.origin.y = menuViewFrame.maxY
        separatorViewFrame.size.height = separatorWeight
        separatorView.frame = separatorViewFrame

        // Workspace view
        var workspaceViewFrame = CGRect(origin: .zero, size: view.bounds.size)
        workspaceViewFrame.origin.y = separatorViewFrame.maxY
        workspaceViewFrame.size.height -= workspaceViewFrame.minY
        workspaceView.frame = workspaceViewFrame
    }

    func closeView() {
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }

}


// MARK: - Workspace menu

extension WorkspaceViewController {

    private func closeWorkspace(_ action: UIAction) {
        guard let rootController = parent as? RootViewController else {
            fatalError()
        }
        rootController.closeWorkspace()
    }

}


// MARK: - Table data source

extension WorkspaceViewController: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return displayFiles.count
    }

    private func fetchWorkspaceFiles() {
        self.workspaceFiles = WorkspaceManager.shared.fetchRemoteWorkspaceFiles(skipsHidden: false)

        self.displayFiles = workspaceFiles.filter(shouldShowFile)

        for file in workspaceFiles {
            let identifier = WorkspaceViewCellIdentifier(file: file)
            workspaceView.register(WorkspaceViewCell.self, forCellReuseIdentifier: identifier.string)
        }
    }

    private func shouldShowFile(_ file: WorkspaceFile) -> Bool {
        return !foldDirectories.contains(where: { file.uri != $0 && file.uri.hasPrefix($0) })
    }

}


// MARK: - Create cell

extension WorkspaceViewController {

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let file = displayFiles[indexPath.row]
        let identifier = WorkspaceViewCellIdentifier(file: file).string

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
                let file = workspaceFiles.first(where: { tableCell.uri == $0.uri }),
                let rootController = parent as? RootViewController else {
            fatalError()
        }

        if file.type == .file {
            rootController.willOpen(file: file)
        }
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
            return (startIndex...endIndex).map({ IndexPath(row: $0, section: 0) })
        }
    }

}
