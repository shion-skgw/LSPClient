//
//  EditorTabViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

final class EditorTabViewController: UIViewController {
    /// Tab container view
    private(set) weak var tabContainer: EditorTabView!
    /// Editor container view
    private(set) weak var editorContainer: UIView!

    /// Tab container view height
    private let tabViewHeight: CGFloat = 30
    /// Tab item width
    private let tabWidth: CGFloat = 140

    /// Active document URI
    private(set) var activeDocumentUri: DocumentUri?

    var editorControllers: [EditorViewController] {
        children.compactMap({ $0 as? EditorViewController })
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Tab container view
        let tabContainer = EditorTabView()
        view.addSubview(tabContainer)
        self.tabContainer = tabContainer

        // Editor container view
        let editorContainer = UIView()
        view.addSubview(editorContainer)
        self.editorContainer = editorContainer

        // Notification
        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)

        refreshCodeStyle()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        // Tab container view
        var tabContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        tabContainerFrame.size.height = tabViewHeight
        tabContainer.frame = tabContainerFrame

        // Editor container view
        var editorContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        editorContainerFrame.origin.y = tabContainerFrame.maxY
        editorContainerFrame.size.height -= editorContainerFrame.minY
        editorContainer.frame = editorContainerFrame

        // Editor view
        let editorViewFrame = CGRect(origin: .zero, size: editorContainerFrame.size)
        editorContainer.subviews.forEach({ $0.frame = editorViewFrame })
    }

    ///
    /// Refresh code style
    ///
    @objc private func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()
        tabContainer.backgroundColor = codeStyle.tabAreaColor
        tabContainer.tabItems.forEach({ $0.set(codeStyle: codeStyle) })
        editorContainer.backgroundColor = codeStyle.backgroundColor
    }

}

extension EditorTabViewController {

    // MARK: - Editor open control

    func open(uri: DocumentUri) {
        if editorControllers.contains(where: { $0.uri == uri }) {
            select(uri: uri)

        } else {
            appendTab(uri: uri)
            appendEditor(uri: uri)
            select(uri: uri)
        }
    }

    private func appendTab(uri: DocumentUri) {
        // Calc tab item frame
        var tabItemFrame = CGRect(origin: .zero, size: tabContainer.bounds.size)
        tabItemFrame.size.width = tabWidth
        tabItemFrame.size.height -= 1

        // Add tab item
        let tabItem = EditorTabItem(frame: tabItemFrame)
        tabItem.uri = uri
        tabItem.set(codeStyle: CodeStyle.load())
        tabItem.addTarget(self, action: #selector(select(sender:)), for: .touchUpInside)
        tabItem.closeButton.addTarget(self, action: #selector(close(sender:)), for: .touchUpInside)
        tabContainer.add(item: tabItem)
    }

    private func appendEditor(uri: DocumentUri) {
        let editor = EditorViewController()
        editor.uri = uri
        addChild(editor)
        editorContainer.addSubview(editor.view)
        editor.didMove(toParent: self)
    }


    // MARK: - Editor select control

    func select(uri: DocumentUri) {
        tabContainer.tabItems.forEach({ $0.isActive = $0.uri == uri })
        editorControllers.forEach({
            if $0.uri == uri {
                self.activeDocumentUri = uri
                $0.view.isHidden = false
                $0.view.becomeFirstResponder()
            } else {
                $0.view.isHidden = true
                $0.view.resignFirstResponder()
            }
        })
    }

    @objc private func select(sender: EditorTabItem) {
        select(uri: sender.uri)
    }


    // MARK: - Editor close control

    func close(uri: DocumentUri) {
        guard let editor = editorControllers.first(where: { $0.uri == uri }),
                let tabItem = tabContainer.tabItems.first(where: { $0.uri == uri }) else {
            return
        }

        if let nextEditorURI = nextEditorURI(uri) {
            select(uri: nextEditorURI)
        }

        // Remove EditorViewController
        editor.willMove(toParent: nil)
        editor.view.removeFromSuperview()
        editor.removeFromParent()

        // Remove tab
        tabContainer.remove(item: tabItem)
    }

    @objc private func close(sender: EditorTabCloseButton) {
        close(uri: sender.uri)
    }

    private func nextEditorURI(_ uri: DocumentUri) -> DocumentUri? {
        guard let current = tabContainer.tabItems.firstIndex(where: { $0.uri == uri }) else {
            fatalError()
        }

        let maxIndex = tabContainer.tabItems.count - 1

        if maxIndex >= current + 1 {
            return tabContainer.tabItems[current + 1].uri
        } else if current - 1 >= .zero {
            return tabContainer.tabItems[current - 1].uri
        } else {
            return nil
        }
    }

}
