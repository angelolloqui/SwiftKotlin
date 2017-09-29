//
//  Tokenizer+Extensions.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 26/08/2017.
//
import Foundation
import Transform
import AST
import Source
import Parser

public extension Tokenizer {

    public func translate(path: URL) throws -> [Token] {
        let content = try String(contentsOf: path)
        let source = SourceFile(path: path.absoluteString, content: content)
        return try translate(source: source)
    }

    public func translate(content: String) throws -> [Token] {
        let source = SourceFile(content: content)
        return try translate(source: source)
    }

    private func translate(source: SourceFile) throws -> [Token] {
        let parser = Parser(source: source)
        let topLevelDecl = try parser.parse()
        return tokenize(topLevelDecl)
    }

}

extension Collection where Iterator.Element == [Token] {
    public func joined(tokens: [Token]) -> [Token] {
        return Array(self.filter { !$0.isEmpty }.flatMap { $0 + tokens }.dropLast(tokens.count))
    }

    public func joined() -> [Token] {
        return self.flatMap { $0 }
    }
}
