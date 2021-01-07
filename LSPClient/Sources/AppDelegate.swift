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

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        CodeStyle.remove()
        var a = CodeStyle.load()
        a.backgroundColor.uiColor = UIColor.brown
        a.save()
//        a.backgroundColor.uiColor = UIColor.lightGray
//        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14.0, weight: .regular)
//        a.save()



        let rootViewController = RootViewController()
        rootViewController.view.backgroundColor = UIColor.systemBackground

        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        return true
    }

}
