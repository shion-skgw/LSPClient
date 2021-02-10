//
//  SidebarMenuViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SidebarMenuViewController: UIViewController {

    weak var rootController: RootViewController!
    private(set) weak var sidebarMenuView: SidebarMenuView!

    override func loadView() {
        let sidebarMenuView = SidebarMenuView()
        let tapAction = UIAction(handler: menuTapAction(_:))
        sidebarMenuView.workspaceButton.addAction(tapAction, for: .touchUpInside)
        sidebarMenuView.consoleButton.addAction(tapAction, for: .touchUpInside)
        sidebarMenuView.diagnosticsButton.addAction(tapAction, for: .touchUpInside)
        self.sidebarMenuView = sidebarMenuView
        self.view = sidebarMenuView
    }

    private func menuTapAction(_ action: UIAction) {
        guard let sender = action.sender as? UIButton else {
            fatalError()
        }

        if sender == sidebarMenuView.workspaceButton {
            rootController.showWorkspace()

        } else if sender == sidebarMenuView.consoleButton {
            rootController.showWorkspace()

        } else if sender == sidebarMenuView.diagnosticsButton {
            rootController.showWorkspace()

        } else {
            fatalError()
        }
    }

}
