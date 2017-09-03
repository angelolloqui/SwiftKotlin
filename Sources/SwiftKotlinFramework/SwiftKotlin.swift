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
    override open var indentation: String {
        return "    "
    }
}

public class KotlinTokenizer: SwiftTokenizer {

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

    open override func tokenize(_ parameter: FunctionSignature.Parameter, node: ASTNode) -> [Token] {
        let nameTokens = [
            parameter.newToken(.identifier, parameter.localName, node)
        ]
        let typeAnnoTokens = tokenize(parameter.typeAnnotation, node: node)
        let defaultTokens = parameter.defaultArgumentClause.map {
            return parameter.newToken(.symbol, " = ", node) + tokenize($0)
        }
        let varargsTokens = parameter.isVarargs ? [parameter.newToken(.symbol, "...", node)] : []

        return
            nameTokens +
                typeAnnoTokens +
                defaultTokens +
        varargsTokens
    }

    open override func tokenize(_ result: FunctionResult, node: ASTNode) -> [Token] {
        return super.tokenize(result, node: node)
            .replacing({ $0.value == "->"},
                       with: [result.newToken(.symbol, ":", node)])
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

    // MARK: - Statements

    open override func tokenize(_ statement: GuardStatement) -> [Token] {
        let invertedConditions = statement.conditionList.map(InvertedCondition.init)
        return
            tokenizeDeclarationConditions(statement.conditionList, node: statement) +
            [
                [statement.newToken(.keyword, "if")],
                tokenize(invertedConditions, node: statement),
                tokenize(statement.codeBlock)
            ].joined(token: statement.newToken(.space, " "))
    }

    open override func tokenize(_ statement: IfStatement) -> [Token] {
        return tokenizeDeclarationConditions(statement.conditionList, node: statement) +
            super.tokenize(statement)
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

    open override func tokenize(_ expression: FunctionCallExpression.Argument, node: ASTNode) -> [Token] {
        return super.tokenize(expression, node: node)
            .replacing({ $0.value == ": " && $0.kind == .delimiter },
                       with: [expression.newToken(.delimiter, " = ", node)])
    }


    // MARK: - Types

    open override func tokenize(_ type: FunctionType, node: ASTNode) -> [Token] {
        return super.tokenize(type, node: node)
            .replacing({ $0.value == "Void" && $0.kind == .identifier },
                       with: [type.newToken(.identifier, "Unit", node)])
    }

    // MARK: - Utils

    open override func tokenize(_ conditions: ConditionList, node: ASTNode) -> [Token] {
        return conditions.map { tokenize($0, node: node) }
            .joined(token: node.newToken(.delimiter, " && "))
            .prefix(with: node.newToken(.startOfScope, "("))
            .suffix(with: node.newToken(.endOfScope, ")"))
    }

    open override func tokenize(_ condition: Condition, node: ASTNode) -> [Token] {
        switch condition {
        case let .let(pattern, _):
            return tokenizeNullCheck(pattern: pattern, condition: condition, node: node)
        case let .var(pattern, _):
            return tokenizeNullCheck(pattern: pattern, condition: condition, node: node)
        default:
            return super.tokenize(condition, node: node)
        }
    }


    // MARK: - Private helpers

    private func tokenizeDeclarationConditions(_ conditions: ConditionList, node: ASTNode) -> [Token] {
        var declarationTokens = [Token]()
        for condition in conditions {
            switch condition {
            case .let, .var:
                declarationTokens.append(contentsOf: super.tokenize(condition, node: node))
                declarationTokens.append(condition.newToken(.linebreak, "\n", node))
            default: continue
            }
        }
        return declarationTokens
    }

    private func tokenizeNullCheck(pattern: AST.Pattern, condition: Condition, node: ASTNode) -> [Token] {
        return [
            tokenize(pattern, node: node),
            [condition.newToken(.symbol, "!=", node)],
            [condition.newToken(.keyword, "null", node)],
        ].joined(token: condition.newToken(.space, " ", node))
    }


    open func tokenize(_ conditions: InvertedConditionList, node: ASTNode) -> [Token] {
        return conditions.map { tokenize($0, node: node) }
            .joined(token: node.newToken(.delimiter, " || "))
            .prefix(with: node.newToken(.startOfScope, "("))
            .suffix(with: node.newToken(.endOfScope, ")"))
    }

    private func tokenize(_ condition: InvertedCondition, node: ASTNode) -> [Token] {
        let tokens = tokenize(condition.condition, node: node)
        var invertedTokens = [Token]()
        var inverted = false
        var lastExpressionIndex = 0
        for token in tokens {
            if let origin = token.origin, let node = token.node {
                if origin is SequenceExpression || origin is BinaryExpression || origin is Condition {
                    let inversionMap = [
                        "==": "!=",
                        "!=": "==",
                        ">": "<=",
                        ">=": "<",
                        "<": ">=",
                        "<=": ">",
                        "is": "!is",
                    ]
                    if let newValue = inversionMap[token.value] {
                        inverted = true
                        invertedTokens.append(origin.newToken(token.kind, newValue, node))
                        continue
                    } else if token.value == "&&" || token.value == "||" {
                        if !inverted {
                            invertedTokens.insert(origin.newToken(.symbol, "!", node), at: lastExpressionIndex)
                        }
                        inverted = false
                        invertedTokens.append(origin.newToken(token.kind, token.value == "&&" ? "||" : "&&", node))
                        lastExpressionIndex = invertedTokens.count + 1
                        continue
                    }
                } else if origin is PrefixOperatorExpression {
                    if token.value == "!" {
                        inverted = true
                        continue
                    }
                }
            }
            invertedTokens.append(token)
        }
        if !inverted {
            invertedTokens.insert(condition.newToken(.symbol, "!", node), at: lastExpressionIndex)
        }
        return invertedTokens
    }
}

public typealias InvertedConditionList = [InvertedCondition]
public struct InvertedCondition: ASTTokenizable {
    public let condition: Condition
}

