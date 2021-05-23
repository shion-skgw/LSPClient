//
//  CacheType.swift
//  LSPClient
//
//  Created by Shion on 2021/05/22.
//  Copyright © 2021 Shion. All rights reserved.
//

protocol CacheType {

    /// Cache
    static var cache: Self? { get set }

    ///
    /// Initialize
    ///
    init()

}

extension CacheType {

    ///
    /// Initialize cache
    ///
    /// - Returns: initial value
    ///
    static func initialize() -> Self {
        let value = Self.init()
        value.save()
        return value
    }

    ///
    /// Load cache
    ///
    /// - Returns: cache
    ///
    static func load() -> Self {
        if let value = cache {
            return value
        } else {
            return initialize()
        }
    }

    ///
    /// Save cache
    ///
    func save() {
        Self.cache = self
    }

}
