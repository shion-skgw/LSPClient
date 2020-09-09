//
//  ConfigType.swift
//  LSPClient
//
//  Created by Shion on 2020/08/05.
//  Copyright © 2020 Shion. All rights reserved.
//

import Foundation

protocol ConfigType: Codable {
	static var configKey: String { get }
	init()
}

extension ConfigType {

	static func load() -> Self {
		if let data = UserDefaults.standard.data(forKey: Self.configKey) {
			do {
				return try JSONDecoder().decode(self, from: data)
			} catch {
				fatalError(error.localizedDescription)
			}
		} else {
			let date = Self.init()
			date.save()
			return date
		}
	}

	func save() {
		do {
			let data = try JSONEncoder().encode(self)
			UserDefaults.standard.set(data, forKey: Self.configKey)
		} catch {
			fatalError(error.localizedDescription)
		}
	}

}
