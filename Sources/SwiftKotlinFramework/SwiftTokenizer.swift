//
//  SwiftTokenizer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 14/10/2017.
//

import Foundation
import Transform
import AST
import Source
import Parser
import Tooling
import Diagnostic

public class SwiftTokenizer: Tokenizer {
    override open var indentation: String {
        return "    "
    }

    open var sourceTransformPlugins: [SourceTransformPlugin]
    open var tokenTransformPlugins: [TokenTransformPlugin]

    public init(sourceTransformPlugins: [SourceTransformPlugin] = [],
         tokenTransformPlugins: [TokenTransformPlugin] = []) {
        self.sourceTransformPlugins = sourceTransformPlugins
        self.tokenTransformPlugins = tokenTransformPlugins
    }
    
    open func translate(paths: [URL]) -> [TokenizationResult] {
        var errorResults = [TokenizationResult]()
        let sourceFiles = paths.compactMap { path -> SourceFile? in
            do {
                let content = try String(contentsOf: path)
                return SourceFile(path: path.absoluteString, content: content)
            } catch let exception {
                errorResults.append(
                    TokenizationResult(sourceFile: SourceFile(path: path.absoluteString, content: ""),
                                       diagnostics: [],
                                       tokens: nil,
                                       exception: exception)
                )
                return nil
            }
        }
        return translate(sourceFiles: sourceFiles)
    }

    open func translate(path: URL) -> TokenizationResult {
        return translate(paths: [path]).first!
    }
    
    open func translate(content: String) -> TokenizationResult {
        let source = SourceFile(content: content)
        return translate(sourceFiles: [source]).first!
    }

}

extension SwiftTokenizer {

    private func applySourceTransformPlugins(sourceFile: SourceFile) throws -> SourceFile {
        let transformedSourceContent = try sourceTransformPlugins.reduce(sourceFile.content) { source, plugin in
            return try plugin.transform(source: source)
        }
        switch sourceFile.origin {
        case .file(let path):
            return SourceFile(path: path, content: transformedSourceContent)
        case .memory(let uuid):
            return SourceFile(uuid: uuid, content: transformedSourceContent)
        }
    }

    private func applyTokenTransformPlugins(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        return try tokenTransformPlugins.reduce(tokens) { tokens, plugin in
            return try plugin.transform(tokens: tokens, topDeclaration: topDeclaration)
        }
    }
    
    private func translate(declaration: TopLevelDeclaration) throws -> [Token] {
        let tokens = tokenize(declaration)
        return try applyTokenTransformPlugins(tokens: tokens, topDeclaration: declaration)
    }
    
    private func translate(sourceFiles: [SourceFile]) -> [TokenizationResult] {
        var errorResults = [TokenizationResult]()
        
        // Apply source transformation plugins
        let transformedSourceFiles = sourceFiles.compactMap { sourceFile -> SourceFile? in
            do {
                return try self.applySourceTransformPlugins(sourceFile: sourceFile)
            } catch let exception {
                errorResults.append(TokenizationResult(
                    sourceFile: sourceFile,
                    diagnostics: [],
                    tokens: nil,
                    exception: exception
                ))
                return nil
            }
        }
        
        // Generate AST
        let diagnosticConsumer = AggregatedDiagnosticConsumer()
        let tooling = ToolAction()
        let result = tooling.run(
            sourceFiles: transformedSourceFiles,
            diagnosticConsumer: diagnosticConsumer,
            options: [.foldSequenceExpression, .assignLexicalParent]
        )
        
        // Tokenize AST back to [Token]
        let successfulResults = result.astUnitCollection.compactMap { unit -> TokenizationResult? in
            guard let sourceFile = unit.sourceFile else {
                return nil
            }
            let diagnostics = diagnosticConsumer.diagnostics.filter { diagnostic in
                diagnostic.location.identifier == sourceFile.identifier
            }
            do {
                let tokens = try translate(declaration: unit.translationUnit)
                return TokenizationResult(
                    sourceFile: sourceFile,
                    diagnostics: diagnostics,
                    tokens: tokens,
                    exception: nil
                )
            } catch let error {
                return TokenizationResult(
                    sourceFile: sourceFile,
                    diagnostics: diagnostics,
                    tokens: nil,
                    exception: error
                )
            }
        }
        
        // Add unparsed files with diagnostics
        errorResults.append(contentsOf: result.unparsedSourceFiles.map { sourceFile -> TokenizationResult in
            let diagnostics = diagnosticConsumer.diagnostics.filter { diagnostic in
                diagnostic.location.identifier == sourceFile.identifier
            }
            return TokenizationResult(
                sourceFile: sourceFile,
                diagnostics: diagnostics,
                tokens: nil,
                exception: nil)
            }
        )
        
        return successfulResults + errorResults
    }
}

private class AggregatedDiagnosticConsumer: DiagnosticConsumer {
    var diagnostics: [Diagnostic] = []
    
    func consume(diagnostics: [Diagnostic]) {
        self.diagnostics.append(contentsOf: diagnostics)
    }
}

