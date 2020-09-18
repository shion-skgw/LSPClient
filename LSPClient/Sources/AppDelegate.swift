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
        var a = CodeStyle.load()
        a.backgroundColor.uiColor = UIColor.lightGray
        a.font.uiFont = UIFont.monospacedSystemFont(ofSize: 14.0, weight: .regular)
        a.fontColor.uiColor = UIColor.darkGray
        a.save()
        let window = UIWindow(frame: UIScreen.main.bounds)
//        window.rootViewController = UIViewController()
//        window.rootViewController?.addChild(EditorViewController())
        window.rootViewController = EditorViewController()
        window.backgroundColor = .lightGray
        window.makeKeyAndVisible()
        self.window = window
        return true
    }

}
