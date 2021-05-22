//
//  WorkspaceConfigViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/03/05.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class WorkspaceConfigViewController: UIViewController {

    private(set) weak var workspaceConfig: WorkspaceConfigView!

    override func loadView() {
        let workspaceConfig = WorkspaceConfigView()
        self.workspaceConfig = workspaceConfig
        self.view = workspaceConfig
    }

    override func viewDidLayoutSubviews() {
        let workspaceConfigFrame = CGRect(origin: .zero, size: view.bounds.size)
        workspaceConfig.frame = workspaceConfigFrame
    }

}
