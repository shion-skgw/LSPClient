//
//  LocationLink.swift
//  LSPClient
//
//  Created by Shion on 2020/06/12.
//  Copyright © 2020 Shion. All rights reserved.
//

struct LocationLink: Codable {
	let originSelectionRange: TextRange?
	let targetUri: DocumentUri
	let targetRange: TextRange
	let targetSelectionRange: TextRange
}
