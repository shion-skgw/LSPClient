| Name | Method | Support |
| --- | --- | :-: |
| Cancellation Support | `$/cancelRequest` | ○ |
| Progress Support | `$/progress` | - |
| Initialize Request | `initialize` | ○ |
| Initialized Notification | `initialized` | ○ |
| Shutdown Request | `shutdown` | ○ |
| Exit Notification | `exit` | ○ |
| ShowMessage Notification | `window/showMessage` | ○ |
| ShowMessage Request | `window/showMessageRequest` | ○ |
| LogMessage Notification | `window/logMessage` | ○ |
| Creating Work Done Progress | `window/workDoneProgress/create` | - |
| Canceling a Work Done Progress | `window/workDoneProgress/cancel` | - |
| Telemetry Notification | `telemetry/event` | - |
| Register Capability | `client/registerCapability` | - |
| Unregister Capability | `client/unregisterCapability` | - |
| Workspace folders request | `workspace/workspaceFolders` | - |
| DidChangeWorkspaceFolders Notification | `workspace/didChangeWorkspaceFolders` | - |
| DidChangeConfiguration Notification | `workspace/didChangeConfiguration` | ○ |
| Configuration Request | `workspace/configuration` | - |
| DidChangeWatchedFiles Notification | `workspace/didChangeWatchedFiles` | ○ |
| Workspace Symbols Request | `workspace/symbol` | ○ |
| Execute a command | `workspace/executeCommand` | ○ |
| Applies a WorkspaceEdit | `workspace/applyEdit` | ○ |
| DidOpenTextDocument Notification | `textDocument/didOpen` | ○ |
| DidChangeTextDocument Notification | `textDocument/didChange` | ○ |
| WillSaveTextDocument Notification | `textDocument/willSave` | - |
| WillSaveWaitUntilTextDocument Request | `textDocument/willSaveWaitUntil` | - |
| DidSaveTextDocument Notification | `textDocument/didSave` | ○ |
| DidCloseTextDocument Notification | `textDocument/didClose` | ○ |
| PublishDiagnostics Notification | `textDocument/publishDiagnostics` | ○ |
| Completion Request | `textDocument/completion` | ○ |
| Completion Item Resolve Request | `completionItem/resolve` | ○ |
| Hover Request | `textDocument/hover` | ○ |
| Signature Help Request | `textDocument/signatureHelp` | - |
| Goto Declaration Request | `textDocument/declaration` | - |
| Goto Definition Request | `textDocument/definition` | ○ |
| Goto Type Definition Request | `textDocument/typeDefinition` | ○ |
| Goto Implementation Request | `textDocument/implementation` | ○ |
| Find References Request | `textDocument/references` | ○ |
| Document Highlights Request | `textDocument/documentHighlight` | ○ |
| Document Symbols Request | `textDocument/documentSymbol` | ○ |
| Code Action Request | `textDocument/codeAction` | ○ |
| Code Lens Request | `textDocument/codeLens` | - |
| Code Lens Resolve Request | `codeLens/resolve` | - |
| Document Link Request | `textDocument/documentLink` | - |
| Document Link Resolve Request | `documentLink/resolve` | - |
| Document Color Request | `textDocument/documentColor` | - |
| Color Presentation Request | `textDocument/colorPresentation` | - |
| Document Formatting Request | `textDocument/formatting` | - |
| Document Range Formatting Request | `textDocument/rangeFormatting` | ○ |
| Document on Type Formatting Request | `textDocument/onTypeFormatting` | - |
| Rename Request | `textDocument/rename` | ○ |
| Prepare Rename Request | `textDocument/prepareRename` | - |
| Folding Range Request | `textDocument/foldingRange` | - |
| Selection Range Request | `textDocument/selectionRange` | - |

https://github.com/microsoft/language-server-protocol/blob/gh-pages/_specifications/specification-3-15.md
