//
//  PropertiesType.swift
//  LSPClient
//
//  Created by Shion on 2020/08/02.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

protocol PropertiesType: Codable {
    static var resourceName: String { get }
}

extension PropertiesType {

    init() {
        guard let path = Bundle.main.path(forResource: Self.resourceName, ofType: "plist") else {
            fatalError()
        }
        do {
            let data = try Data(contentsOf: URL(fileURLWithPath: path))
            self = try PropertyListDecoder().decode(Self.self, from: data)
        } catch {
            fatalError()
        }
    }

}
