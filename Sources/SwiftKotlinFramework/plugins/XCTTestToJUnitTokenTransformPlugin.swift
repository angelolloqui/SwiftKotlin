//
//  XCTTestToJUnitTokenTransformPlugin.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 14/10/2017.
//

import Foundation
import Transform
import AST

public class XCTTestToJUnitTokenTransformPlugin: TokenTransformPlugin {
    public var name: String {
        return "XCTest to JUnit4"
    }

    public var description: String {
        return "Transforms XCTTest classes and methods to JUnit4 variants"
    }

    public init() {}

    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        let testClasses = topDeclaration.statements
            .compactMap { $0 as? ClassDeclaration }
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
        if let inheritanceIndex = newTokens.firstIndex(where: { $0.value == "XCTestCase" }) {
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
            .compactMap { $0.declaration as? FunctionDeclaration }
            .filter { $0.name.textDescription.starts(with: method) }
        guard !testMethods.isEmpty else { return tokens }

        var newTokens = tokens
        for method in testMethods {
            if let firstTokenIndex = newTokens.firstIndex(where: { $0.node === method && $0.kind != .linebreak && $0.kind != .indentation }),
                let lineBreakIndex = newTokens.indexOf(kind: .linebreak, before: firstTokenIndex) {
                let indentation = newTokens.lineIndentationToken(at: firstTokenIndex)
                newTokens.insert(method.newToken(.identifier, annotation), at: lineBreakIndex)
                indentation.map { newTokens.insert($0, at: lineBreakIndex) }
                newTokens.insert(method.newToken(.linebreak, "\n"), at: lineBreakIndex)
            }
            newTokens = removeSuperCall(newTokens, node: method)
        }

        return newTokens
    }

    private func removeSuperCall(_ tokens: [Token], node: FunctionDeclaration) -> [Token] {
        guard node.modifiers.contains(.override) else { return tokens }
        var newTokens = tokens
        if let overrideIndex = newTokens.firstIndex(where: { $0.node === node && $0.value == "override" }) {
            newTokens.remove(at: overrideIndex)
            newTokens.remove(at: overrideIndex)     // Remove the spacing
        }

        guard let superCallExpression = node.body?.statements
            .compactMap({ $0 as? FunctionCallExpression })
            .filter({ $0.textDescription.starts(with: "super.\(node.name)()") })
            .first else {
                return newTokens
        }
        guard let superIndex = newTokens.firstIndex(where: { $0.node === superCallExpression }) else {
            return newTokens
        }

        let startOfLine = newTokens.indexOf(kind: .linebreak, before: superIndex) ?? 0
        let endOfLine = newTokens.indexOf(kind: .linebreak, after: superIndex) ?? newTokens.count
        newTokens.removeSubrange(startOfLine..<endOfLine)

        return newTokens
    }

    let xctMap = [
        "XCTAssertTrue": (junitName: "assertTrue", parameters: 1),
        "XCTAssertFalse": (junitName: "assertFalse", parameters: 1),
        "XCTAssertNil": (junitName: "assertNull", parameters: 1),
        "XCTAssertNotNil": (junitName: "assertNotNull", parameters: 1),
        "XCTAssertEqual": (junitName: "assertEquals", parameters: 2),
        "XCTAssertNotEqual": (junitName: "assertNotEquals", parameters: 2)
    ]
    private func replaceXCTAssertCalls(_ tokens: [Token], node: TopLevelDeclaration) -> [Token] {
        var newTokens = [Token]()

        var index = 0
        while index < tokens.count {
            let token = tokens[index]

            if let expression = token.node as? IdentifierExpression, let mapping = xctMap[token.value] {

                // Replace method name
                newTokens.append(expression.newToken(.identifier, mapping.junitName))
                index += 1

                // Check parameters
                if let functionCallExpression = tokens[index].origin as? FunctionCallExpression,
                    let endOfLineIndex = tokens.indexOf(kind: .linebreak, after: index) {
                    var remainingLineTokens = Array(tokens[index..<endOfLineIndex])

                    // Put last parameter in first place (JUnit places comments first)
                    if  functionCallExpression.argumentClause?.count ?? 0 > mapping.parameters,
                        let lastDelimiter = remainingLineTokens.indexOf(kind: .delimiter, before: remainingLineTokens.count - 1){
                        let delimiterToken = remainingLineTokens.remove(at: lastDelimiter)
                        let parameterToken = remainingLineTokens.remove(at: lastDelimiter)
                        remainingLineTokens.insert(parameterToken, at: 1)
                        remainingLineTokens.insert(delimiterToken, at: 2)
                    }
                    newTokens.append(contentsOf: remainingLineTokens)
                    index += remainingLineTokens.count
                }
            } else {
                newTokens.append(token)
                index += 1
            }
        }

        return newTokens
    }
}
