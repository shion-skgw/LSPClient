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
        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14, weight: .regular)
        a.backgroundColor.uiColor = UIColor.brown
        a.save()

        WorkspaceManager.shared.initialize(workspaceName: "w", remoteRootUrl: URL(string: "file://asdfasdf:1234/Users/shion/Desktop/")!)

        let rootViewController = RootViewController()
        self.rootViewController = rootViewController

        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        NotificationCenter.default.addObserver(self, selector: #selector(aaa), name: .willOpenDocument, object: nil)

        return true
    }

    @objc func aaa(_ notification: Notification) {
        guard let qwe = notification.userInfoValue as? DocumentUri else {
            fatalError()
        }
        print(qwe)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

}
