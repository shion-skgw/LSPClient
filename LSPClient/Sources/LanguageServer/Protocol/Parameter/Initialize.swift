//
//  Initialize.swift
//  LSPClient
//
//  Created by Shion on 2020/06/24.
//  Copyright © 2020 Shion. All rights reserved.
//

// MARK: - Initialize Request (initialize)

struct InitializeParams: RequestParamsType {
	let processId: RequiredValue<Int>
	let clientInfo: ClientInfo?
	let rootPath: String?
	let rootUri: DocumentUri
	let initializationOptions: AnyValue?
	let capabilities: ClientCapabilities
	let trace: TraceMode?

	init(processId: Int? = nil,
			clientInfo: ClientInfo? = nil,
			rootPath: String? = nil,
			rootUri: DocumentUri,
			initializationOptions: AnyValue? = nil,
			trace: TraceMode? = .off) {
		self.processId = RequiredValue(processId)
		self.clientInfo = clientInfo
		self.rootPath = rootPath
		self.rootUri = rootUri
		self.initializationOptions = initializationOptions
		self.capabilities = ClientCapabilities()
		self.trace = trace
	}
}

extension InitializeParams {
	struct ClientInfo: Codable {
		let name: String
		let version: String?
	}
	enum TraceMode: String, Codable {
		case off = "off"
		case messages = "messages"
		case verbose = "verbose"
	}
}

struct InitializeResult: ResultType {
	let capabilities: ServerCapabilities
	let serverInfo: ServerInfo?
}

extension InitializeResult {
	struct ServerCapabilities: Codable {
		let textDocumentSync: TextDocumentSyncOptions?
		let completionProvider: CompletionOptions?
		let hoverProvider: HoverOptions?
		let declarationProvider: DeclarationOptions?
		let definitionProvider: DefinitionOptions?
		let typeDefinitionProvider: TypeDefinitionOptions?
		let implementationProvider: ImplementationOptions?
		let referencesProvider: ReferenceOptions?
		let documentHighlightProvider: DocumentHighlightOptions?
		let documentSymbolProvider: DocumentSymbolOptions?
		let codeActionProvider: CodeActionOptions?
		let documentFormattingProvider: DocumentFormattingOptions?
		let documentRangeFormattingProvider: DocumentRangeFormattingOptions?
		let renameProvider: RenameOptions?
		let executeCommandProvider: ExecuteCommandOptions?
		let workspaceSymbolProvider: WorkspaceSymbolOptions?
		let experimental: AnyValue?
	}

	struct ServerInfo: Codable {
		let name: String
		let version: String?
	}
}

extension InitializeResult.ServerCapabilities {

	struct TextDocumentSyncOptions: Codable {
		let openClose: Bool?
		let change: TextDocumentSyncKind?

		private enum CodingKeys: String, CodingKey {
			case openClose
			case change
		}

		init(from decoder: Decoder) throws {
			if let value = try? decoder.singleValueContainer().decode(TextDocumentSyncKind.self) {
				self.openClose = nil
				self.change = value
			} else {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				self.openClose = try container.decode(Bool?.self, forKey: .openClose)
				self.change = try container.decode(TextDocumentSyncKind?.self, forKey: .change)
			}
		}
	}

	enum TextDocumentSyncKind: Int, Codable {
		case none = 0
		case full = 1
		case incremental = 2
	}

	struct CompletionOptions: Codable {
		let triggerCharacters: [String]?
		let allCommitCharacters: [String]?
		let resolveProvider: Bool?
	}

	struct HoverOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct DeclarationOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct DefinitionOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct TypeDefinitionOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct ImplementationOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct ReferenceOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct DocumentHighlightOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct DocumentSymbolOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct CodeActionOptions: Codable {
		let isSupport: Bool
		let codeActionKinds: [CodeActionKind]?

		private enum CodingKeys: String, CodingKey {
			case codeActionKinds
		}

		init(from decoder: Decoder) throws {
			if let value = try? decoder.singleValueContainer().decode(Bool.self) {
				self.isSupport = value
				self.codeActionKinds = nil
			} else {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				self.isSupport = true
				self.codeActionKinds = try container.decode([CodeActionKind]?.self, forKey: .codeActionKinds)
			}
		}
	}

	struct DocumentFormattingOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct DocumentRangeFormattingOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

	struct RenameOptions: Codable {
		let isSupport: Bool
		let prepareProvider: Bool?

		private enum CodingKeys: String, CodingKey {
			case prepareProvider
		}

		init(from decoder: Decoder) throws {
			if let value = try? decoder.singleValueContainer().decode(Bool.self) {
				self.isSupport = value
				self.prepareProvider = nil
			} else {
				let container = try decoder.container(keyedBy: CodingKeys.self)
				self.isSupport = true
				self.prepareProvider = try container.decode(Bool?.self, forKey: .prepareProvider)
			}
		}
	}

	struct ExecuteCommandOptions: Codable {
		let commands: [String]
	}

	struct WorkspaceSymbolOptions: Codable {
		let isSupport: Bool

		init(from decoder: Decoder) throws {
			let value = try decoder.singleValueContainer().decode(AnyValue.self)
			self.isSupport = value.value as? Bool == true || !(value.value is Void)
		}
	}

}


// MARK: - Initialized Notification (initialized)

struct InitializedParams: NotificationParamsType {
}
