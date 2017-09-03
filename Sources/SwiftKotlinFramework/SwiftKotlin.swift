//
//  SwiftKotlin.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 14/09/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation
import Transform
import AST
import Source
import Parser

public class SwiftTokenizer: Tokenizer {
}

public class KotlinTokenizer: Tokenizer {
    public init() {
    }


    // MARK: - Declarations

    open override func tokenize(_ constant: ConstantDeclaration) -> [Token] {
        return super.tokenize(constant)
            .replacing({ $0.value == "let"},
                       with: [constant.newToken(.keyword, "val")])
    }

    open override func tokenize(_ declaration: FunctionDeclaration) -> [Token] {
        return super.tokenize(declaration)
            .replacing({ $0.value == "func"},
                       with: [declaration.newToken(.keyword, "fun")])
    }

    open override func tokenize(_ member: ProtocolDeclaration.MethodMember, node: ASTNode) -> [Token] {
        return super.tokenize(member, node: node)
            .replacing({ $0.value == "func"},
                       with: [member.newToken(.keyword, "fun", node)])
    }

    open override func tokenize(_ declaration: StructDeclaration) -> [Token] {
        return super.tokenize(declaration)
            .replacing({ $0.value == "struct"},
                       with: [declaration.newToken(.keyword, "data class")])
    }

    open override func tokenize(_ declaration: ProtocolDeclaration) -> [Token] {
        return super.tokenize(declaration)
            .replacing({ $0.value == "protocol"},
                       with: [declaration.newToken(.keyword, "interface")])
    }

    open override func tokenize(_ modifier: AccessLevelModifier, node: ASTNode) -> [Token] {
        return [modifier.newToken(
            .keyword,
            modifier.rawValue.replacingOccurrences(of: "fileprivate", with: "private"),
            node)]
    }


    // MARK: - Expressions

    open override func tokenize(_ expression: LiteralExpression) -> [Token] {
        switch expression.kind {
        case .nil:
            return [expression.newToken(.keyword, "null")]
        case .array(let exprs):
            return
                expression.newToken(.identifier, "arrayOf") +
                expression.newToken(.startOfScope, "(") +
                exprs.map { tokenize($0) }.joined(token: expression.newToken(.delimiter, ", ")) +
                expression.newToken(.endOfScope, ")")
        case .dictionary(let entries):
            return
                expression.newToken(.identifier, "mapOf") +
                expression.newToken(.startOfScope, "(") +
                entries.map { tokenize($0, node: expression) }
                    .joined(token: expression.newToken(.delimiter, ", ")) +
                expression.newToken(.endOfScope, ")")
        default:
            return super.tokenize(expression)
        }
    }

    open override func tokenize(_ entry: DictionaryEntry, node: ASTNode) -> [Token] {
        return tokenize(entry.key) +
            entry.newToken(.delimiter, " to ", node) +
            tokenize(entry.value)
    }

    open override func tokenize(_ expression: SelfExpression) -> [Token] {
        return super.tokenize(expression)
            .replacing({ $0.value == "self"},
                       with: [expression.newToken(.keyword, "this")])
    }

    open override func tokenize(_ expression: IdentifierExpression) -> [Token] {
        switch expression.kind {
        case let .implicitParameterName(i, generic) where i == 0:
            return expression.newToken(.identifier, "it") +
                generic.map { tokenize($0, node: expression) }
        default:
            return super.tokenize(expression)
        }
    }

    open override func tokenize(_ expression: BinaryOperatorExpression) -> [Token] {
        return super.tokenize(expression)
            .replacing({ $0.value == "??"},
                       with: [expression.newToken(.symbol, "?:")])
    }
}

