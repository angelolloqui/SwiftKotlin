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

    open override func tokenize(_ declaration: ClassDeclaration) -> [Token] {
        let staticMembers = declaration.members.filter({ $0.isStatic })
        let newClass = ClassDeclaration(
            attributes: declaration.attributes,
            accessLevelModifier: declaration.accessLevelModifier,
            isFinal: declaration.isFinal,
            name: declaration.name,
            genericParameterClause: declaration.genericParameterClause,
            typeInheritanceClause: declaration.typeInheritanceClause,
            genericWhereClause: declaration.genericWhereClause,
            members: declaration.members.filter({ !$0.isStatic }))
        var tokens = super.tokenize(newClass)
        if !staticMembers.isEmpty, let bodyStart = tokens.index(where: { $0.value == "{"}) {
            let companionTokens = indent(tokenizeCompanion(staticMembers, node: declaration))
                .prefix(with: declaration.newToken(.linebreak, "\n"))
                .suffix(with: declaration.newToken(.linebreak, "\n"))
            tokens.insert(contentsOf: companionTokens, at: bodyStart + 1)
        }

        return tokens
    }

    open override func tokenize(_ declaration: StructDeclaration) -> [Token] {
        let staticMembers = declaration.members.filter({ $0.isStatic })
        let newStruct = StructDeclaration(
            attributes: declaration.attributes,
            accessLevelModifier: declaration.accessLevelModifier,
            name: declaration.name,
            genericParameterClause: declaration.genericParameterClause,
            typeInheritanceClause: declaration.typeInheritanceClause,
            genericWhereClause: declaration.genericWhereClause,
            members: declaration.members.filter({ !$0.isStatic }))
        var tokens = super.tokenize(newStruct)
            .replacing({ $0.value == "struct"},
                       with: [declaration.newToken(.keyword, "data class")])

        if !staticMembers.isEmpty, let bodyStart = tokens.index(where: { $0.value == "{"}) {
            let companionTokens = indent(tokenizeCompanion(staticMembers, node: declaration))
                .prefix(with: declaration.newToken(.linebreak, "\n"))
                .suffix(with: declaration.newToken(.linebreak, "\n"))
            tokens.insert(contentsOf: companionTokens, at: bodyStart + 1)
        }

        return tokens
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

    open override func tokenize(_ declaration: InitializerDeclaration) -> [Token] {
        return super.tokenize(declaration)
            .replacing({ $0.value == "init"},
                       with: [declaration.newToken(.keyword, "constructor")])
    }

    open override func tokenize(_ modifier: DeclarationModifier, node: ASTNode) -> [Token] {
        switch modifier {
        case .static, .unowned, .unownedSafe, .unownedUnsafe, .weak:
            return []
        default:
            return super.tokenize(modifier, node: node)
        }
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


    open override func tokenize(_ statement: SwitchStatement) -> [Token] {
        var tokens = super.tokenize(statement)
        if let startIndex = tokens.index(where: { $0.origin is Expression }),
            let endIndex = tokens.index(where: { $0.value == "{"}) {
            tokens.insert(statement.newToken(.endOfScope, ")"), at: endIndex - 1)
            tokens.insert(statement.newToken(.startOfScope, "("), at: startIndex)
        }
        return tokens.replacing({ $0.value == "switch" },
                                with: [statement.newToken(.keyword, "when")])
    }

    open override func tokenize(_ statement: SwitchStatement.Case, node: ASTNode) -> [Token] {
        let separatorTokens =  [
            statement.newToken(.space, " ", node),
            statement.newToken(.delimiter, "->", node),
            statement.newToken(.linebreak, "\n", node)
        ]
        switch statement {
        case let .case(itemList, stmts):
            let prefix = itemList.count > 1 ? [statement.newToken(.keyword, "in", node), statement.newToken(.space, " ", node)] : []
            let conditions = itemList.map { tokenize($0, node: node) }.joined(token: statement.newToken(.delimiter, ", ", node))
            return prefix + conditions + separatorTokens + indent(tokenize(stmts, node: node))

        case .default(let stmts):
            return
                [statement.newToken(.keyword, "else", node)] +
                    separatorTokens +
                    indent(tokenize(stmts, node: node))
        }
    }

    open override func tokenize(_ statement: ForInStatement) -> [Token] {
        var tokens = super.tokenize(statement)
        if let endIndex = tokens.index(where: { $0.value == "{"}) {
            tokens.insert(statement.newToken(.endOfScope, ")"), at: endIndex - 1)
            tokens.insert(statement.newToken(.startOfScope, "("), at: 2)
        }
        return tokens
    }

    // MARK: - Expressions

    open override func tokenize(_ expression: LiteralExpression) -> [Token] {
        switch expression.kind {
        case .nil:
            return [expression.newToken(.keyword, "null")]
        case let .interpolatedString(_, rawText):
            return tokenizeInterpolatedString(rawText, node: expression)
        case .array(let exprs):
            return
                expression.newToken(.identifier, "listOf") +
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

    open override func tokenize(_ expression: ClosureExpression) -> [Token] {
        var tokens = super.tokenize(expression)
        if expression.signature != nil {
            tokens = tokens.replacing({ $0.value == "in" },
                                      with: [expression.newToken(.symbol, " -> ")],
                                      amount: 1)
        }
        return tokens
    }

    open override func tokenize(_ expression: ClosureExpression.Signature, node: ASTNode) -> [Token] {
        return expression.parameterClause.map { tokenize($0, node: node) } ?? []
    }

    open override func tokenize(_ expression: ClosureExpression.Signature.ParameterClause, node: ASTNode) -> [Token] {
        switch expression {
        case .parameterList(let params):
            return params.map { tokenize($0, node: node) }.joined(token: expression.newToken(.delimiter, ", ", node))
        default:
            return super.tokenize(expression, node: node)
        }
    }

    open override func tokenize(_ expression: ClosureExpression.Signature.ParameterClause.Parameter, node: ASTNode) -> [Token] {
        return [expression.newToken(.identifier, expression.name, node)]
    }

    open override func tokenize(_ expression: TryOperatorExpression) -> [Token] {
        switch expression.kind {
        case .try(let expr):
            return tokenize(expr)
        case .forced(let expr):
            return tokenize(expr)
        case .optional(let expr):
            let catchSignature = [
                expression.newToken(.startOfScope, "("),
                expression.newToken(.identifier, "e"),
                expression.newToken(.delimiter, ":"),
                expression.newToken(.space, " "),
                expression.newToken(.identifier, "Throwable"),
                expression.newToken(.endOfScope, ")"),
            ]
            let catchBodyTokens = [
                expression.newToken(.startOfScope, "{"),
                expression.newToken(.space, " "),
                expression.newToken(.keyword, "null"),
                expression.newToken(.space, " "),
                expression.newToken(.endOfScope, "}"),
            ]
            return [
                [expression.newToken(.keyword, "try")],
                [expression.newToken(.startOfScope, "{")],
                tokenize(expr),
                [expression.newToken(.endOfScope, "}")],
                [expression.newToken(.keyword, "catch")],
                catchSignature,
                catchBodyTokens
            ].joined(token: expression.newToken(.space, " "))
        }
    }

    // MARK: - Types
    open override func tokenize(_ type: ArrayType, node: ASTNode) -> [Token] {
        return
            type.newToken(.identifier, "List", node) +
            type.newToken(.startOfScope, "<", node) +
            tokenize(type.elementType, node: node) +
            type.newToken(.endOfScope, ">", node)
    }

    open override func tokenize(_ type: DictionaryType, node: ASTNode) -> [Token] {
        let keyTokens = tokenize(type.keyType, node: node)
        let valueTokens = tokenize(type.valueType, node: node)
        return
            [type.newToken(.identifier, "Map", node), type.newToken(.startOfScope, "<", node)] +
            keyTokens +
            [type.newToken(.delimiter, ", ", node)] +
            valueTokens +
            [type.newToken(.endOfScope, ">", node)]
    }

    open override func tokenize(_ type: FunctionType, node: ASTNode) -> [Token] {
        return super.tokenize(type, node: node)
            .replacing({ $0.value == "Void" && $0.kind == .identifier },
                       with: [type.newToken(.identifier, "Unit", node)])
    }

    open override func tokenize(_ type: TypeIdentifier.TypeName, node: ASTNode) -> [Token] {
        let typeMap = [
            "Bool": "Boolean",
            "AnyObject": "Any"
        ]
        return type.newToken(.identifier, typeMap[type.name] ?? type.name, node) +
            type.genericArgumentClause.map { tokenize($0, node: node) }
    }

    // MARK: - Patterns


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
                declarationTokens.append(contentsOf:
                    super.tokenize(condition, node: node)
                        .replacing({ $0.value == "let" },
                                   with: [condition.newToken(.keyword, "val", node)]))
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


    private func tokenizeCompanion(_ members: [StructDeclaration.Member], node: ASTNode) -> [Token] {
        return tokenizeCompanion(members.flatMap { $0.declaration }, node: node)
    }

    private func tokenizeCompanion(_ members: [ClassDeclaration.Member], node: ASTNode) -> [Token] {
        return tokenizeCompanion(members.flatMap { $0.declaration }, node: node)
    }

    private func tokenizeCompanion(_ members: [Declaration], node: ASTNode) -> [Token] {
        let membersTokens = indent(members.map(tokenize)
            .joined(token: node.newToken(.linebreak, "\n")))

        return [
            [
                node.newToken(.keyword, "companion"),
                node.newToken(.space, " "),
                node.newToken(.keyword, "object"),
                node.newToken(.space, " "),
                node.newToken(.startOfScope, "{")
            ],
            membersTokens,
            [
                node.newToken(.endOfScope, "}")
            ]
        ].joined(token: node.newToken(.linebreak, "\n"))
    }

    private func tokenizeInterpolatedString(_ rawText: String, node: ASTNode) -> [Token] {
        var remainingText = rawText
        var interpolatedString = ""

        while let startRange = remainingText.range(of: "\\(") {
            interpolatedString += remainingText[..<startRange.lowerBound]
            remainingText = String(remainingText[startRange.upperBound...])

            var scopes = 1
            var i = 1
            while i < remainingText.count && scopes > 0 {
                let index = remainingText.index(remainingText.startIndex, offsetBy: i)
                i += 1
                switch remainingText[index] {
                case "(": scopes += 1
                case ")": scopes -= 1
                default: continue
                }
            }
            let expression = String(remainingText[..<remainingText.index(remainingText.startIndex, offsetBy: i - 1)])
            let computedExpression = (try? translate(content: expression).joinedValues().replacingOccurrences(of: "\n", with: "")) ?? expression
            interpolatedString += "${\(computedExpression)}"
            remainingText = String(remainingText[remainingText.index(remainingText.startIndex, offsetBy: i)...])
        }

        interpolatedString += remainingText
        return [node.newToken(.string, interpolatedString)]
    }
}

public typealias InvertedConditionList = [InvertedCondition]
public struct InvertedCondition: ASTTokenizable {
    public let condition: Condition
}

