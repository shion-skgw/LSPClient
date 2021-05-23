//
//  Diagnosis.swift
//  LSPClient
//
//  Created by Shion on 2021/05/22.
//  Copyright © 2021 Shion. All rights reserved.
//

struct Diagnosis: CacheType {

    static var cache: Diagnosis?

    private var value: [DocumentUri: [Diagnostic]] = [:]

    subscript(_ uri: DocumentUri) -> [Diagnostic]? {
        get {
            self.value[uri]
        }
        set {
            self.value[uri] = newValue
        }
    }

}
