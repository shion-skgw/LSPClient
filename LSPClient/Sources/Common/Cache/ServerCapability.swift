//
//  ServerCapability.swift
//  LSPClient
//
//  Created by Shion on 2021/05/23.
//  Copyright © 2021 Shion. All rights reserved.
//

struct ServerCapability: CacheType {

    static var cache: ServerCapability?

    let textDocumentSync: TextDocumentSync
    let completion: Completion
    let hover: SupportAvailable
    let signatureHelp: SignatureHelp
    let declaration: SupportAvailable
    let definition: SupportAvailable
    let typeDefinition: SupportAvailable
    let implementation: SupportAvailable
    let references: SupportAvailable
    let documentHighlight: SupportAvailable
    let documentSymbol: SupportAvailable
    let codeAction: CodeAction
    let documentFormatting: SupportAvailable
    let documentRangeFormatting: SupportAvailable
    let rename: Rename
    let executeCommand: ExecuteCommand
    let workspaceSymbol: SupportAvailable

    init() {
        fatalError()
    }

    init(capabilities: InitializeResult.ServerCapabilities) {
        self.textDocumentSync = TextDocumentSync(capabilities.textDocumentSync)
        self.completion = Completion(capabilities.completionProvider)
        self.hover = SupportAvailable(capabilities.hoverProvider?.isSupport)
        self.signatureHelp = SignatureHelp(capabilities.signatureHelpProvider)
        self.declaration = SupportAvailable(capabilities.declarationProvider?.isSupport)
        self.definition = SupportAvailable(capabilities.definitionProvider?.isSupport)
        self.typeDefinition = SupportAvailable(capabilities.typeDefinitionProvider?.isSupport)
        self.implementation = SupportAvailable(capabilities.implementationProvider?.isSupport)
        self.references = SupportAvailable(capabilities.referencesProvider?.isSupport)
        self.documentHighlight = SupportAvailable(capabilities.documentHighlightProvider?.isSupport)
        self.documentSymbol = SupportAvailable(capabilities.documentSymbolProvider?.isSupport)
        self.codeAction = CodeAction(capabilities.codeActionProvider)
        self.documentFormatting = SupportAvailable(capabilities.documentFormattingProvider?.isSupport)
        self.documentRangeFormatting = SupportAvailable(capabilities.documentRangeFormattingProvider?.isSupport)
        self.rename = Rename(capabilities.renameProvider)
        self.executeCommand = ExecuteCommand(capabilities.executeCommandProvider)
        self.workspaceSymbol = SupportAvailable(capabilities.workspaceSymbolProvider?.isSupport)
    }

}

extension ServerCapability {

    struct TextDocumentSync {
        let openClose: Bool
        let change: InitializeResult.ServerCapabilities.TextDocumentSyncKind

        init(_ option: InitializeResult.ServerCapabilities.TextDocumentSyncOptions?) {
            self.openClose = option?.openClose ?? false
            self.change = option?.change ?? .none
        }
    }

    struct Completion {
        let isSupport: Bool
        let triggerCharacters: [String]
        let allCommitCharacters: [String]
        let resolveProvider: Bool

        init(_ option: InitializeResult.ServerCapabilities.CompletionOptions?) {
            var allCommitCharacters: Set<String> = ["\n", "\t"]
            option?.allCommitCharacters?.forEach({ allCommitCharacters.insert($0) })

            self.isSupport = option != nil
            self.triggerCharacters = option?.triggerCharacters ?? []
            self.allCommitCharacters = Array(allCommitCharacters)
            self.resolveProvider = option?.resolveProvider ?? false
        }
    }

    struct SignatureHelp {
        let isSupport: Bool
        let triggerCharacters: [String]
        let retriggerCharacters: [String]

        init(_ option: InitializeResult.ServerCapabilities.SignatureHelpOptions?) {
            self.isSupport = option != nil
            self.triggerCharacters = option?.triggerCharacters ?? []
            self.retriggerCharacters = option?.retriggerCharacters ?? []
        }
    }

    struct CodeAction {
        let isSupport: Bool
        let codeActionKinds: [CodeActionKind]

        init(_ option: InitializeResult.ServerCapabilities.CodeActionOptions?) {
            self.isSupport = option?.isSupport ?? false
            self.codeActionKinds = option?.codeActionKinds ?? []
        }
    }

    struct Rename {
        let isSupport: Bool
        let prepareProvider: Bool

        init(_ option: InitializeResult.ServerCapabilities.RenameOptions?) {
            self.isSupport = option?.isSupport ?? false
            self.prepareProvider = option?.prepareProvider ?? false
        }
    }

    struct ExecuteCommand {
        let isSupport: Bool
        let commands: [String]

        init(_ option: InitializeResult.ServerCapabilities.ExecuteCommandOptions?) {
            self.isSupport = option != nil
            self.commands = option?.commands ?? []
        }
    }

    struct SupportAvailable {
        let isSupport: Bool

        init(_ isSupport: Bool?) {
            self.isSupport = isSupport ?? false
        }
    }

}
