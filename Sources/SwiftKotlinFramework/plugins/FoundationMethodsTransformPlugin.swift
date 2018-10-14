//
//  FoundationMethodsTransformPlugin.swift
//  SwiftKotlinPackageDescription
//
//  Created by Angel Luis Garcia on 10/12/2017.
//

import Foundation
import Transform
import AST

public class FoundationMethodsTransformPlugin: TokenTransformPlugin {
    public var name: String {
        return "Foundation transformations"
    }

    public var description: String {
        return "Transforms methods on lists, maps,... like `first`, `count`... to their Kotlin variant"
    }

    public init() {}

    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        var newTokens = [Token]()

        for token in tokens {
            if token.kind == .identifier,
                let memberExpression = token.origin as? ExplicitMemberExpression,
                case ExplicitMemberExpression.Kind.namedType(let expression, let identifier) = memberExpression.kind,
                let inferredType = inferTypeFor(expression: expression, topDeclaration: topDeclaration),
                let replace = memberStringMappings[inferredType]?[identifier.textDescription] {
                newTokens.append(memberExpression.newToken(.identifier, replace))
            } else if token.kind == .identifier, token.value == "fatalError", let origin = token.origin, let node = token.node {
                newTokens.append(origin.newToken(.keyword, "throw", node))
                newTokens.append(origin.newToken(.space, " ", node))
                newTokens.append(origin.newToken(.identifier, "Exception", node))
            } else {
                newTokens.append(token)
            }
        }

        return newTokens
    }

    func inferTypeFor(expression: PostfixExpression, topDeclaration: TopLevelDeclaration) -> String? {
        // TODO: Right now there is no way to infer types. Will be fixed in future versions of AST
        return "List"
    }

    let memberStringMappings = [
        "List": [
            "first": "firstOrNull()",
            "last":  "lastOrNull()",
            "count": "size",
            "isEmpty": "isEmpty()"
        ],
        "String": [
            "count": "length",
            "uppercased": "toUpperCase",
            "lowercased": "toLowerCase"
        ]
    ]

    // TODO: How to map regex expressions that affect multiple tokens?
    let memberRegexMappings = [
        "List": [
            "index(of: \\(.+))": "indexOf($1)",
            "append(\\(.+))": "add($1)",
            "remove(at: \\(.+))": "removeAt($1)",
            "sorted(by: \\(.+))": "sortedWith(comparator = Comparator($1))",
            "joined(separator: \\(.+))": "joinToString(separator = $1)"
        ]
    ]
}
