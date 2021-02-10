//
//  AppDelegate.swift
//  LSPClient
//
//  Created by Shion on 2020/06/07.
//  Copyright © 2020 Shion. All rights reserved.
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate, MessageManagerDelegate, ApplicationMessageDelegate {

    var window: UIWindow?
    weak var rootViewController: RootViewController!

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
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



extension AppDelegate {

    func shutdown(id: RequestID, result: Result<VoidValue?, ErrorResponse>) {
        print(#function)
        print(id)
        print(result)
    }

    func initialize(id: RequestID, result: Result<InitializeResult, ErrorResponse>) {
        print(#function)
        print(id)
        print(result)
    }

    func applyEdit(id: RequestID, params: ApplyWorkspaceEditParams) {
        print(#function)
        print(id)
        print(params)
    }

    func showMessageRequest(id: RequestID, params: ShowMessageRequestParams) {
        print(#function)
        print(id)
        print(params)
    }

    func connectionError(cause: Error) {
        print(#function)
        print(cause)
    }

    func messageParseError(cause: Error, message: Message?) {
        print(#function)
        print(cause)
        print(message)
    }

    func cancelRequest(params: CancelParams) {
        print(#function)
        print(params)
    }

    func showMessage(params: ShowMessageParams) {
        print(#function)
        print(params)
    }

    func logMessage(params: LogMessageParams) {
        print(#function)
        print(params)
    }

    func publishDiagnostics(params: PublishDiagnosticsParams) {
        print(#function)
        print(params)
    }

}
