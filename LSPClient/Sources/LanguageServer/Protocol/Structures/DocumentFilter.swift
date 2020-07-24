//
//  DocumentFilter.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

struct DocumentFilter: Codable {
	let language: LanguageID?
	let scheme: String?
	let pattern: String?
}

typealias DocumentSelector = [DocumentFilter]
