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
        guard hasXCTests(topDeclaration: topDeclaration) else { return tokens }

        var newTokens = tokens
        newTokens = addImports(newTokens, node: topDeclaration)

        return newTokens
    }

    private func hasXCTests(topDeclaration: TopLevelDeclaration) -> Bool {
        for statement in topDeclaration.statements {
            if isXCTTestClass(statement: statement) {
                return true
            }
        }
        return false
    }

    private func isXCTTestClass(statement: Statement) -> Bool {
        guard let classDeclaration = statement as? ClassDeclaration else { return false }
        return classDeclaration.typeInheritanceClause?.typeInheritanceList.filter {
            $0.textDescription.contains("XCTestCase")
        }.first != nil
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
}
