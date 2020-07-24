//
//  LocationLink.swift
//  LSPClient
//
//  Created by Shion on 2020/06/12.
//  Copyright © 2020 Shion. All rights reserved.
//

struct LocationLink: Codable {
	let originSelectionRange: Range?
	let targetUri: DocumentUri
	let targetRange: Range
	let targetSelectionRange: Range
}
