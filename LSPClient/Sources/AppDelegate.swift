//
//  AppDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?
    weak var rootViewController: RootViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CodeStyle.remove()
        var a = CodeStyle.load()
        a.backgroundColor.uiColor = UIColor.brown
        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: UIFont.systemFontSize, weight: .medium)
        a.save()
//        a.backgroundColor.uiColor = UIColor.lightGray
//        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14.0, weight: .regular)
//        a.save()

        WorkspaceManager.shared.initialize(workspaceName: "w", workspaceUrl: URL(string: "file:///Users/shion/Desktop/z/")!, host: "host", port: 1)
        WorkspaceManager.shared.copy(documentUri: URL(string: "file:///Users/shion/Desktop/z/cc/1.jpg")!, source: .remote, destination: .original)

        let rootViewController = RootViewController()
        rootViewController.view.backgroundColor = UIColor.systemBackground
        self.rootViewController = rootViewController

        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window

        return true
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

}
