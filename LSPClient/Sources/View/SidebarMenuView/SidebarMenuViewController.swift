//
//  SidebarMenuViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SidebarMenuViewController: UIViewController {

    private weak var sidebarMenuView: SidebarMenuView!

    override func loadView() {
        let sidebarMenuView = SidebarMenuView()
        sidebarMenuView.workspaceButton.addAction(showWorkspace, for: .touchUpInside)
        sidebarMenuView.consoleButton.addAction(showConsole, for: .touchUpInside)
        sidebarMenuView.diagnosticButton.addAction(showDiagnostic, for: .touchUpInside)
        self.sidebarMenuView = sidebarMenuView
        self.view = sidebarMenuView
    }

    private func showWorkspace(_: UIAction) {
        guard let rootController = parent as? RootViewController else {
            fatalError()
        }
        rootController.showWorkspace()
        view.isHidden = true
    }

    private func showConsole(_: UIAction) {
        guard let rootController = parent as? RootViewController else {
            fatalError()
        }
        rootController.showConsole()
        sidebarMenuView.consoleButton.isHidden = true
        sidebarMenuView.diagnosticButton.isHidden = true
    }

    private func showDiagnostic(_: UIAction) {
        guard let rootController = parent as? RootViewController else {
            fatalError()
        }
        rootController.showDiagnostic()
        sidebarMenuView.consoleButton.isHidden = true
        sidebarMenuView.diagnosticButton.isHidden = true
    }

    func didCloseWorkspace() {
        view.isHidden = false
    }

    func didCloseConsole() {
        sidebarMenuView.consoleButton.isHidden = false
        sidebarMenuView.diagnosticButton.isHidden = false
    }

    func didCloseDiagnostic() {
        sidebarMenuView.consoleButton.isHidden = false
        sidebarMenuView.diagnosticButton.isHidden = false
    }

}
