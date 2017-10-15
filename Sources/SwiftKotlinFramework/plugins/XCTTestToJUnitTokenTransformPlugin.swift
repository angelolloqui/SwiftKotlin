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
        newTokens = replaceXCTAssertCalls(newTokens, node: topDeclaration)

        for testClass in testClasses {
            newTokens = removeXCTestInheritance(newTokens, node: testClass)
            newTokens = addMethodAnnotations(newTokens, node: testClass, method: "setUp", annotation: "@Before")
            newTokens = addMethodAnnotations(newTokens, node: testClass, method: "tearDown", annotation: "@After")
            newTokens = addMethodAnnotations(newTokens, node: testClass, method: "test", annotation: "@Test")
        }

        return newTokens
    }

    private func addImports(_ tokens: [Token], node: ASTNode) -> [Token] {
        let importTokens = [
            node.newToken(.keyword, "import"),
            node.newToken(.space, " "),
            ]
        return [
            importTokens + node.newToken(.identifier, "org.junit.*"),
            importTokens + node.newToken(.identifier, "org.junit.Assert.*"),
            tokens
            ].joined(token: node.newToken(.linebreak, "\n"))
    }

    private func removeXCTestInheritance(_ tokens: [Token], node: ClassDeclaration) -> [Token] {
        var newTokens = tokens
        if let inheritanceIndex = newTokens.index(where: { $0.value == "XCTestCase" }) {
            newTokens.remove(at: inheritanceIndex)
            if (node.typeInheritanceClause?.typeInheritanceList.count ?? 0) > 1 {
                newTokens.remove(at: inheritanceIndex)
            } else {
                newTokens.remove(at: inheritanceIndex - 1)
            }
        }
        return newTokens
    }

    private func addMethodAnnotations(_ tokens: [Token], node: ClassDeclaration, method: String, annotation: String) -> [Token] {

        let testMethods = node.members
            .flatMap { $0.declaration as? FunctionDeclaration }
            .filter { $0.name.starts(with: method) }
        guard !testMethods.isEmpty else { return tokens }

        var newTokens = tokens
        for method in testMethods {
            if let firstTokenIndex = newTokens.index(where: { $0.node === method }),
                let lineBreakIndex = newTokens.indexOf(kind: .linebreak, before: firstTokenIndex) {
                let indentation = newTokens.lineIndentationToken(at: firstTokenIndex)
                newTokens.insert(method.newToken(.identifier, annotation), at: lineBreakIndex)
                indentation.map { newTokens.insert($0, at: lineBreakIndex) }
                newTokens.insert(method.newToken(.linebreak, "\n"), at: lineBreakIndex)
            }
        }
        return newTokens
    }

    private func removeSuperCall(_ tokens: [Token], node: FunctionDeclaration) -> [Token] {
        // TODO:
        return tokens
    }


    private func replaceXCTAssertCalls(_ tokens: [Token], node: TopLevelDeclaration) -> [Token] {
        // TODO:
        return tokens
    }
}