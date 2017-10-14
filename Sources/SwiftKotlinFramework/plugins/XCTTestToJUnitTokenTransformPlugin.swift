//
//  XCTTestToJUnitTokenTransformPlugin.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 14/10/2017.
//

import Foundation
import Transform
import AST

open class XCTTestToJUnitTokenTransformPlugin: TokenTransformPlugin {
    public var name: String {
        return "XCTest to JUnit4"
    }

    public var description: String {
        return "Transforms XCTTest classes and methods to JUnit4 variants"
    }

    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        let testClasses = topDeclaration.statements
            .flatMap { $0 as? ClassDeclaration }
            .filter { clazz in
                return clazz.typeInheritanceClause?.textDescription.contains("XCTestCase") ?? false
            }

        guard !testClasses.isEmpty else { return tokens }

        var newTokens = tokens
        newTokens = addImports(newTokens, node: topDeclaration)

        for testClass in testClasses {
            newTokens = addTestAnnotations(newTokens, node: testClass)
        }


        return newTokens
    }

    private func addImports(_ tokens: [Token], node: ASTNode) -> [Token] {
        let importTokens = [
            node.newToken(.keyword, "import"),
            node.newToken(.space, " "),
        ]
        return [
            importTokens + node.newToken(.identifier, "junit.framework.Assert"),
            importTokens + node.newToken(.identifier, "org.junit.Before"),
            importTokens + node.newToken(.identifier, "org.junit.Test"),
            tokens
        ].joined(token: node.newToken(.linebreak, "\n"))
    }

    private func addTestAnnotations(_ tokens: [Token], node: ClassDeclaration) -> [Token] {
        let testMethods = node.members
            .flatMap { $0.declaration as? FunctionDeclaration }
            .filter { $0.name.starts(with: "test") }
        guard !testMethods.isEmpty else { return tokens }

        var newTokens = tokens
        for method in testMethods {
            if let firstTokenIndex = newTokens.index(where: { $0.node === method }) {
                let indentation = newTokens.lineIndentationToken(at: firstTokenIndex)
                indentation.map { newTokens.insert($0, at: firstTokenIndex) }
                newTokens.insert(method.newToken(.linebreak, "\n"), at: firstTokenIndex)
                newTokens.insert(method.newToken(.identifier, "@Test"), at: firstTokenIndex)
            }
        }
        return newTokens
    }
}
