//
//  ConfigType.swift
//  LSPClient
//
//  Created by Shion on 2020/08/05.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

///
/// ConfigType
///
protocol ConfigType: Codable {

    /// Identification key value
    static var configKey: String { get }
    /// Cache
    static var cache: Self? { get set }

    ///
    /// Initialize
    ///
    init()

}

extension ConfigType {

    static var hasValue: Bool {
        UserDefaults.standard.object(forKey: Self.configKey) != nil
    }

    ///
    /// Initialize config
    ///
    /// - Returns: initial value
    ///
    static func initialize() -> Self {
        let value = Self.init()
        value.save()
        return value
    }

    ///
    /// Load config
    ///
    /// - Returns: config
    ///
    static func load() -> Self {
        if let value = cache {
            return value
        }

        if let data = UserDefaults.standard.data(forKey: Self.configKey),
                let value = try? JSONDecoder().decode(self, from: data) {
            return value
        } else {
            return initialize()
        }
    }

    ///
    /// Remove config
    ///
    static func remove() {
        UserDefaults.standard.removeObject(forKey: Self.configKey)
        cache = nil
    }

    ///
    /// Save config
    ///
    func save() {
        do {
            let data = try JSONEncoder().encode(self)
            UserDefaults.standard.set(data, forKey: Self.configKey)
            Self.cache = self
        } catch {
            fatalError(error.localizedDescription)
        }
    }

}
