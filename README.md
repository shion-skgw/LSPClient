# LSPClient

# LSP Support
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

# Operation Verification
1. Install Python language server

https://github.com/palantir/python-language-server

2. Start with TCP

`pyls --tcp --port 2085 --host 192.168.0.13 -v`

3. Correct and start

https://github.com/shion-skgw/LSPClient/blob/master/LSPClient/Sources/View/RootView/RootViewController.swift#L47-L54

# Reference materials
## Language server protocol
https://github.com/microsoft/language-server-protocol/blob/gh-pages/_specifications/specification-3-15.md

## UIKit
- [ViewControllerのライフサイクル](https://shiba1014.medium.com/viewcontrollerのライフサイクル-37151427bda5)
- [iOSのレイアウトサイクル勉強した](http://thunder-runner.hatenablog.com/entry/2018/06/10/215714)
- [これが最強のMVC(iOS)](https://qiita.com/koitaro/items/b3a924245fd72f22871a)
- [dark mode 小まとめ](https://qiita.com/nagisawks/items/21048f32e9f0afd070e3)
- [subview.frame = view.bounds よりも良い書き方](https://qiita.com/mishimay/items/e9ecf3f352aad4433c24)
- [【iOS】drawRect、CALayer、UIImageViewで描画速度を検証してみた](https://qiita.com/marty-suzuki/items/a28269ee39b6e0ec0830)

## TextKit
- [NSAttributedString と TextKit](https://azu.github.io/slide/OCStudy/2013_November/nsattributedstring.html)
- [iOSのフォントのお話](http://akisute.com/2016/09/ios.html)
- [Objectiv-CのUITextViewで不可視文字を表示する。](https://www.paveway.info/entry/2019/01/06/objc_invisiblechar)

## UITextView
- [UITextView内のカーソル位置をCGRectで取得する](https://h3poteto.hatenablog.com/entry/2015/07/03/000034)
- [iOSでキーボードショートカットに対応する](https://qiita.com/kowloon/items/ceb03e6c288b31e24f79)
- [UIMenuControllerにMenuItemを追加](http://faboplatform.github.io/SwiftDocs/1.uikit/033_uimenucontroller/)

## UITableView
- [UITableViewCellの再利用を知る](https://shiba1014.medium.com/uitableviewcellの再利用を知る-24f00d68f17d)

## Regex
- [正規表現の先読み・後読みを極める！](https://abicky.net/2010/05/30/135112/)
- [Regex word boundaries with Unicode](https://shiba1014.medium.com/regex-word-boundaries-with-unicode-207794f6e7ed)
- [regex101](https://regex101.com)

## Other tips
- [筋肉SwiftプログラマーになるためのARCトレーニング](https://qiita.com/haranicle/items/184d5165353063fcc7c6)
- [Swiftのfinal・private・Whole Module Optimizationを理解しDynamic Dispatchを減らして、パフォーマンスを向上する](https://qiita.com/mono0926/items/f5f271b7d2bde68207b2)
- [Swift5.1のattribute全解説｜全27種](https://qiita.com/shtnkgm/items/2cba98b545c913d990bc)
- [SwiftのARCとクロージャのキャプチャ](https://scior.hatenablog.com/entry/2018/12/24/132704)

