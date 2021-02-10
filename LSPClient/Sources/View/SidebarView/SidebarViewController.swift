//
//  SidebarViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/10.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class SidebarViewController: UIViewController {

    weak var rootController: RootViewController!
    private(set) weak var sidebarView: SidebarView!

    override func loadView() {
        let sidebarView = SidebarView()
        let tapAction = UIAction(handler: menuTapAction(_:))
        sidebarView.workspaceButton.addAction(tapAction, for: .touchUpInside)
        sidebarView.consoleButton.addAction(tapAction, for: .touchUpInside)
        sidebarView.diagnosticsButton.addAction(tapAction, for: .touchUpInside)
        self.sidebarView = sidebarView
        self.view = sidebarView
    }

    private func menuTapAction(_ action: UIAction) {
        guard let sender = action.sender as? UIButton else {
            fatalError()
        }

        if sender == sidebarView.workspaceButton {
            rootController.showWorkspace()

        } else if sender == sidebarView.consoleButton {
            rootController.showWorkspace()

        } else if sender == sidebarView.diagnosticsButton {
            rootController.showWorkspace()

        } else {
            fatalError()
        }
    }

}
