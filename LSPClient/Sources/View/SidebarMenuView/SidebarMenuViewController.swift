//
//  SidebarMenuViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SidebarMenuViewController: UIViewController {

    private(set) weak var sidebarMenuView: SidebarMenuView!

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

    private func showConsole(_: UIAction) {}

    private func showDiagnostic(_: UIAction) {}

}
