//
//  TextDocumentItem.swift
//  LSPClient
//
//  Created by Shion on 2020/06/14.
//  Copyright © 2020 Shion. All rights reserved.
//

struct TextDocumentItem: Codable {
    let uri: DocumentUri
    let languageId: LanguageID
    let version: Int
    let text: String
}

enum LanguageID: String, Codable {
    case ABAP               = "abap"
    case WindowsBat         = "bat"
    case BibTeX             = "bibtex"
    case Clojure            = "clojure"
    case Coffeescript       = "coffeescript"
    case C                  = "c"
    case Cpp                = "cpp"
    case Csharp             = "csharp"
    case CSS                = "css"
    case Diff               = "diff"
    case Dart               = "dart"
    case Dockerfile         = "dockerfile"
    case Elixir             = "elixir"
    case Erlang             = "erlang"
    case Fsharp             = "fsharp"
    case GitCommit          = "git-commit"
    case GitRebase          = "git-rebase"
    case Go                 = "go"
    case Groovy             = "groovy"
    case Handlebars         = "handlebars"
    case HTML               = "html"
    case Ini                = "ini"
    case Java               = "java"
    case JavaScript         = "javascript"
    case JavaScriptReact    = "javascriptreact"
    case JSON               = "json"
    case LaTeX              = "latex"
    case Less               = "less"
    case Lua                = "lua"
    case Makefile           = "makefile"
    case Markdown           = "markdown"
    case ObjectiveC         = "objective-c"
    case ObjectiveCpp       = "objective-cpp"
    case Perl               = "perl"
    case Perl6              = "perl6"
    case PHP                = "php"
    case Powershell         = "powershell"
    case Pug                = "jade"
    case Python             = "python"
    case R                  = "r"
    case Razor              = "razor"
    case Ruby               = "ruby"
    case Rust               = "rust"
    case SCSS               = "scss"
    case SCSS_Indented      = "sass"
    case Scala              = "scala"
    case ShaderLab          = "shaderlab"
    case ShellScript        = "shellscript"
    case SQL                = "sql"
    case Swift              = "swift"
    case TypeScript         = "typescript"
    case TypeScriptReact    = "typescriptreact"
    case TeX                = "tex"
    case VisualBasic        = "vb"
    case XML                = "xml"
    case XSL                = "xsl"
    case YAML               = "yaml"

    static func of(fileExtension: String) -> Self {
        switch fileExtension {
        case "swift":
            return .Swift
        case "py":
            return .Python
        default:
            fatalError()
        }
    }
}
