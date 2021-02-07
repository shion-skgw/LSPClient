//
//  EditorTabViewController.swift
//  LSPClient
//
//  Created by Shion on 2021/01/04.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit
import OSLog

final class EditorTabViewController: UIViewController {

    private(set) weak var tabContainer: EditorTabView!
    private(set) weak var editorContainer: UIView!

    let tabViewHeight: CGFloat = UIFont.systemFontSize * 2
    let tabWidth: CGFloat = 140

    private var currentTagNumber = 0
    private var nextTagNumber: Int {
        currentTagNumber += 1
        return currentTagNumber
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        let codeStyle = CodeStyle.load()

        let tabContainer = EditorTabView()
        tabContainer.backgroundColor = codeStyle.tabAreaColor.uiColor
        view.addSubview(tabContainer)
        self.tabContainer = tabContainer

        let editorContainer = UIView()
        editorContainer.backgroundColor = codeStyle.backgroundColor.uiColor
        view.addSubview(editorContainer)
        self.editorContainer = editorContainer

        let notificationCenter = NotificationCenter.default
        notificationCenter.addObserver(self, selector: #selector(refreshCodeStyle), name: .didChangeCodeStyle, object: nil)
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        var tabContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        tabContainerFrame.size.height = tabViewHeight
        tabContainer.frame = tabContainerFrame

        var editorContainerFrame = CGRect(origin: .zero, size: view.bounds.size)
        editorContainerFrame.origin.y += tabContainerFrame.height
        editorContainerFrame.size.height -= tabContainerFrame.height
        editorContainer.frame = editorContainerFrame

        editorContainer.subviews.forEach({ $0.frame = editorContainerFrame })
    }

    @objc func selectTab(sender: EditorTabItem) {
        tabContainer.tabItems.forEach({ $0.isActive = $0.tag == sender.tag })
        editorContainer.subviews.forEach() {
            if $0.tag == sender.tag {
                $0.isHidden = false
                $0.becomeFirstResponder()
            } else {
                $0.isHidden = true
                $0.resignFirstResponder()
            }
        }
    }

    @objc func closeTab(sender: UIButton) {
        guard let tabItem = tabContainer.tabItems.filter({ $0.tag == sender.tag }).first,
                let controller = children.filter({ $0.view.tag == sender.tag }).first else {
            return
        }

        tabContainer.remove(item: tabItem)
        controller.willMove(toParent: nil)
        controller.view.removeFromSuperview()
        controller.removeFromParent()

        if tabContainer.tabItems.filter({ $0.isActive }).isEmpty,
                let lastAddTab = tabContainer.tabItems.max(by: { $0.tag < $1.tag }) {
            selectTab(sender: lastAddTab)
        }
    }

    func addTab(title: String, viewController: EditorViewController) {
        let tagNumber = nextTagNumber

        // Add child controller
        viewController.view.tag = tagNumber
        viewController.view.frame = editorContainer.bounds
        addChild(viewController)
        editorContainer.addSubview(viewController.view)
        viewController.didMove(toParent: self)

        // Add tab
        let tabItemFrame = CGRect(x: .zero, y: .zero, width: tabWidth, height: tabViewHeight - 2)
        let tabItem = EditorTabItem(frame: tabItemFrame)
        tabItem.set(title: title)
        tabItem.set(codeStyle: CodeStyle.load())
        tabItem.set(tagNumber: tagNumber)
        tabItem.addTarget(self, action: #selector(selectTab(sender:)), for: .touchUpInside)
        tabItem.closeButton.addTarget(self, action: #selector(closeTab(sender:)), for: .touchUpInside)
        tabContainer.add(item: tabItem)

        // Select tab
        selectTab(sender: tabItem)
    }

    @objc func refreshCodeStyle() {
        let codeStyle = CodeStyle.load()
        tabContainer.backgroundColor = .secondarySystemBackground
        tabContainer.tabItems.forEach({ $0.set(codeStyle: codeStyle) })
        editorContainer.backgroundColor = codeStyle.backgroundColor.uiColor
    }

}
