//
//  EditorUndoManager.swift
//  LSPClient
//
//  Created by Shion on 2021/01/25.
//  Copyright © 2021 Shion. All rights reserved.
//

import Foundation

final class EditorUndoManager: UndoManager {
//
//    weak var editorView: EditorView?
//    private var currentVersion: Int = .zero
//    private var editHistories: [Int: EditHistory] = [:]
//
//    var editHistory: EditHistory? {
//        editHistories[currentVersion]
//    }
//
//    func appendHistory(location: Int, before: String, after: String) {
//        currentVersion += 1
//        editHistories[currentVersion] = EditHistory(location: location, before: before, after: after)
//    }
//
//    func registerUndo() {
//        guard let editorView = self.editorView else {
//            return
//        }
//        registerUndo(withTarget: editorView, selector: #selector(editorView.undo), object: nil)
//    }
//
//    func registerRedo() {
//        guard let editorView = self.editorView else {
//            return
//        }
//        registerUndo(withTarget: editorView, selector: #selector(editorView.redo), object: nil)
//    }
//
//    override func undo() {
//        super.undo()
//        currentVersion -= 1
//    }
//
//    override func redo() {
//        currentVersion += 1
//        super.redo()
//    }

}

extension EditorUndoManager {

    struct EditHistory {
        let location: Int
        let before: String
        let after: String
    }

}
