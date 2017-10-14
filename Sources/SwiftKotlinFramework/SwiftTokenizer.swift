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

open class SwiftTokenizer: Tokenizer {
    override open var indentation: String {
        return "    "
    }

    open var sourceTransformPlugins: [SourceTransformPlugin] = []
    open var tokenTransformPlugins: [TokenTransformPlugin] = []

    open func translate(path: URL) throws -> [Token] {
        let content = try String(contentsOf: path)
        let transformedContent = try applySourceTransformPlugins(source: content)
        let source = SourceFile(path: path.absoluteString, content: transformedContent)
        return try translate(source: source)
    }

    open func translate(content: String) throws -> [Token] {
        let transformedContent = try applySourceTransformPlugins(source: content)
        let source = SourceFile(content: transformedContent)
        return try translate(source: source)
    }

}

extension SwiftTokenizer {

    private func applySourceTransformPlugins(source: String) throws -> String {
        return try sourceTransformPlugins.reduce(source) { source, plugin in
            return try plugin.transform(source: source)
        }
    }

    private func applyTokenTransformPlugins(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        return try tokenTransformPlugins.reduce(tokens) { tokens, plugin in
            return try plugin.transform(tokens: tokens, topDeclaration: topDeclaration)
        }
    }

    private func translate(source: SourceFile) throws -> [Token] {
        let parser = Parser(source: source)
        let topLevelDecl = try parser.parse()
        let tokens = tokenize(topLevelDecl)
        return try applyTokenTransformPlugins(tokens: tokens, topDeclaration: topLevelDecl)
    }
}
