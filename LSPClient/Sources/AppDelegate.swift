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


        print(URL(string: "file:///Users/shion/Desktop/z/bb/1.jpg")!.scheme)
        WorkspaceManager.shared.initialize(workspaceName: "w", remoteRootUrl: URL(string: "file://asdfasdf:1234/Users/shion/Desktop/")!)
        WorkspaceManager.shared.fetchRemoteWorkspaceFiles(skipsHidden: true).forEach({ print($0.uri) })
//        print(WorkspaceManager.shared.copy(uri: URL(string: "file:///Users/shion/Desktop/z/bb/1.jpg")!, from: .remote, to: .local, isForced: true))
        print(WorkspaceManager.shared.remove(uri: URL(string: "file:///Users/shion/Desktop/z/bb/1.jpg")!, source: .local))

//        let q = try! URL(string: "file:///Users/shion/Desktop/z/bb/1.jpg")!.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier!
//        let w = try! URL(string: "file:///Users/shion/Library/Developer/CoreSimulator/Devices/C97299D8-06BF-432C-BF30-83BB8BCCED06/data/Containers/Data/Application/05EB504A-063C-4F44-B384-19CFD2EB7F7C/Library/Application%20Support/com.skgw.LSPClient/w/z/bb/1.jpg")!.resourceValues(forKeys: [.fileResourceIdentifierKey]).fileResourceIdentifier!
//        print(q)
//        print(w)
//        print(q.isEqual(w))

//        let rootViewController = RootViewController()
        let rootViewController = WorkspaceViewController()
        rootViewController.view.backgroundColor = UIColor.systemBackground
//        self.rootViewController = rootViewController

        let window = UIWindow()
        window.rootViewController = rootViewController
        window.makeKeyAndVisible()

        self.window = window
        NotificationCenter.default.addObserver(self, selector: #selector(aaa), name: .willOpenDocument, object: nil)

//        MessageManager.shared.delegate = self
//        MessageManager.shared.connection(server: LanguageServer(name: "a", host: "192.168.0.13", port: 12345, comment: ""), method: TCPConnection.shared)
//        print(initialize(params: InitializeParams(rootUri: URL(string: "file:////Users/shion/Documents/PyCharm/Test")!)))
        return true
    }

    @objc func aaa(_ notification: NSNotification) {
        guard let qwe = notification.userInfo?[NotificationUserInfoKey.uri] as? DocumentUri else {
            fatalError()
        }
        print(qwe)
    }

    func applicationDidBecomeActive(_ application: UIApplication) {
    }

    func applicationWillResignActive(_ application: UIApplication) {
    }

}
