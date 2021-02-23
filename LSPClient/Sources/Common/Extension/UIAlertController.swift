//
//  UIAlertController.swift
//  LSPClient
//
//  Created by Shion on 2021/02/18.
//  Copyright © 2021 Shion. All rights reserved.
//

import UIKit

extension UIAlertController {

    static func largeFile(size: Int, limit: Int, acceptAction: @escaping ((UIAlertAction) -> ())) -> UIAlertController {
        let title = "Large file"
        let message = "Size: \(size), Limit: \(limit)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: acceptAction))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }

    static func fileNotFound(uri: DocumentUri) -> UIAlertController {
        let title = "File not found"
        let message = "URI: \(uri)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        return alert
    }

    static func unsupportedFile(uri: DocumentUri) -> UIAlertController {
        let title = "Cannot open file"
        let message = "URI: \(uri)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        return alert
    }

    static func aaa(uri: DocumentUri, acceptAction: @escaping ((UIAlertAction) -> Void)) -> UIAlertController {
        let title = "File exists"
        let message = "URI: \(uri)"
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: acceptAction))
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel))
        return alert
    }

    static func anyAlert(title: String, message: String) -> UIAlertController {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))
        return alert
    }

}
