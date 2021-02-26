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
        sidebarMenuView.backgroundColor = .secondarySystemBackground
        sidebarMenuView.settingButton.addAction(menuAction, for: .touchUpInside)
        sidebarMenuView.workspaceButton.addAction(menuAction, for: .touchUpInside)
        sidebarMenuView.consoleButton.addAction(menuAction, for: .touchUpInside)
        sidebarMenuView.diagnosticButton.addAction(menuAction, for: .touchUpInside)
        self.sidebarMenuView = sidebarMenuView
        self.view = sidebarMenuView
    }

    private func menuAction(_ action: UIAction) {
        guard let sender = action.sender as? UIButton,
                let rootController = parent as? RootViewController else {
            fatalError()
        }

        if sidebarMenuView.settingButton == sender {
            fatalError()

        } else if sidebarMenuView.workspaceButton == sender {
            rootController.showWorkspace()

        } else if sidebarMenuView.consoleButton == sender {
            rootController.showConsole()

        } else if sidebarMenuView.diagnosticButton == sender {
            rootController.showDiagnostic()

        } else {
            fatalError()
        }
    }

}
