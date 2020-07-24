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
	let initializationOptions: AnyValue
	let capabilities: ClientCapabilities
	let trace: TraceMode?
}

extension InitializeParams {
	struct ClientInfo: Codable {
		let name: String
		let version: String?
	}
	struct ClientCapabilities: Codable {
	}
	enum TraceMode: String, Codable {
		case off = "off"
		case messages = "messages"
		case verbose = "verbose"
	}
}

struct InitializeResult: ResultType {
	let capabilities: ServerCapabilities
}

extension InitializeResult {
	struct ServerCapabilities: Codable {
//		textDocumentSync?: TextDocumentSyncOptions | number;
//		completionProvider?: CompletionOptions;
//		hoverProvider?: boolean | HoverOptions;
//		signatureHelpProvider?: SignatureHelpOptions;
//		declarationProvider?: boolean | DeclarationOptions | DeclarationRegistrationOptions;
//		definitionProvider?: boolean | DefinitionOptions;
//		typeDefinitionProvider?: boolean | TypeDefinitionOptions | TypeDefinitionRegistrationOptions;
//		implementationProvider?: boolean | ImplementationOptions | ImplementationRegistrationOptions;
//		referencesProvider?: boolean | ReferenceOptions;
//		documentHighlightProvider?: boolean | DocumentHighlightOptions;
//		documentSymbolProvider?: boolean | DocumentSymbolOptions;
//		codeActionProvider?: boolean | CodeActionOptions;
//		codeLensProvider?: CodeLensOptions;
//		documentLinkProvider?: DocumentLinkOptions;
//		colorProvider?: boolean | DocumentColorOptions | DocumentColorRegistrationOptions;
//		documentFormattingProvider?: boolean | DocumentFormattingOptions;
//		documentRangeFormattingProvider?: boolean | DocumentRangeFormattingOptions;
//		documentOnTypeFormattingProvider?: DocumentOnTypeFormattingOptions;
//		renameProvider?: boolean | RenameOptions;
//		foldingRangeProvider?: boolean | FoldingRangeOptions | FoldingRangeRegistrationOptions;
//		executeCommandProvider?: ExecuteCommandOptions;
//		selectionRangeProvider?: boolean | SelectionRangeOptions | SelectionRangeRegistrationOptions;
//		workspaceSymbolProvider?: boolean;
//		workspace?: {
//			workspaceFolders?: WorkspaceFoldersServerCapabilities;
//		}
//		experimental?: any;
	}
}


// MARK: - Initialized Notification (initialized)

struct InitializedParams: NotificationParamsType {
}
