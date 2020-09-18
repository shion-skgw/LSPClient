//
//  PropertiesType.swift
//  LSPClient
//
//  Created by Shion on 2020/08/02.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

///
/// PropertiesType
///
protocol PropertiesType: Codable {
    /// Resource file name
    static var resourceName: String { get }
    /// Cache
    static var cache: Self? { get set }
}

extension PropertiesType {

    ///
    /// Load properties
    ///
    /// - Returns: Properties
    ///
    static func load() -> Self {
        if let value = cache {
            return value
        }

        guard let path = Bundle.main.path(forResource: Self.resourceName, ofType: "plist") else {
            fatalError()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            return try PropertyListDecoder().decode(Self.self, from: data)
        } catch {
            fatalError()
        }
    }

}
