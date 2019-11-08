//
//  KotlinTokenizer.swift
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

public class KotlinTokenizer: SwiftTokenizer {

    // MARK: - Declarations

    open override func tokenize(_ constant: ConstantDeclaration) -> [Token] {
        return super.tokenize(constant)
            .replacing({ $0.value == "let"},
                       with: [constant.newToken(.keyword, "val")])
    }
    
    open override func tokenize(_ declaration: FunctionDeclaration) -> [Token] {
        let attrsTokens = tokenize(declaration.attributes, node: declaration)
        let modifierTokens = declaration.modifiers.map { tokenize($0, node: declaration) }
            .joined(token: declaration.newToken(.space, " "))
        let genericParameterClauseTokens = declaration.genericParameterClause.map { tokenize($0, node: declaration) } ?? []
        
        let headTokens = [
            attrsTokens,
            modifierTokens,
            [declaration.newToken(.keyword, "fun")],
            genericParameterClauseTokens
        ].joined(token: declaration.newToken(.space, " "))
        
        var signatureTokens = tokenize(declaration.signature, node: declaration)
        let bodyTokens = declaration.body.map(tokenize) ?? []

        if declaration.isOverride {
            // overridden methods can't have default args in kotlin:
            signatureTokens = removeDefaultArgsFromParameters(tokens:signatureTokens)
        }
        let tokens = [
            headTokens,
            [declaration.newToken(.identifier, declaration.name)] + signatureTokens,
            bodyTokens
        ].joined(token: declaration.newToken(.space, " "))
        .prefix(with: declaration.newToken(.linebreak, "\n"))
        
        return tokens
    }

    open override func tokenize(_ parameter: FunctionSignature.Parameter, node: ASTNode) -> [Token] {
        let nameTokens = [
            parameter.newToken(.identifier, parameter.localName, node)
        ]
        let typeAnnoTokens = tokenize(parameter.typeAnnotation, node: node)
        let defaultTokens = parameter.defaultArgumentClause.map {
            return parameter.newToken(.symbol, " = ", node) + tokenize($0)
        }
        let varargsTokens = parameter.isVarargs ? [
            parameter.newToken(.keyword, "vararg", node),
            parameter.newToken(.space, " ", node),
        ] : []

        return
            varargsTokens +
            nameTokens +
            typeAnnoTokens +
            defaultTokens
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
        newClass.setSourceRange(declaration.sourceRange)
        var tokens = super.tokenize(newClass)
        if !staticMembers.isEmpty, let bodyStart = tokens.firstIndex(where: { $0.value == "{"}) {
            let companionTokens = indent(tokenizeCompanion(staticMembers, node: declaration))
                .prefix(with: declaration.newToken(.linebreak, "\n"))
                .suffix(with: declaration.newToken(.linebreak, "\n"))
            tokens.insert(contentsOf: companionTokens, at: bodyStart + 1)
        }

        return tokens
    }

    open override func tokenize(_ declaration: StructDeclaration) -> [Token] {
        var staticMembers: [StructDeclaration.Member] = []
        var declarationMembers: [StructDeclaration.Member] = []
        var otherMembers: [StructDeclaration.Member] = []
        declaration.members.forEach { member in
            if member.isStatic {
                staticMembers.append(member)
            } else if member.declaration is ConstantDeclaration ||
                (member.declaration as? VariableDeclaration)?.initializerList != nil {
                declarationMembers.append(member)
            } else {
                otherMembers.append(member)
            }
        }

        let newStruct = StructDeclaration(
            attributes: declaration.attributes,
            accessLevelModifier: declaration.accessLevelModifier,
            name: declaration.name,
            genericParameterClause: declaration.genericParameterClause,
            typeInheritanceClause: declaration.typeInheritanceClause,
            genericWhereClause: declaration.genericWhereClause,
            members: otherMembers)
        newStruct.setSourceRange(declaration.sourceRange)
        
        var tokens = super.tokenize(newStruct)
            .replacing({ $0.value == "struct"},
                       with: [declaration.newToken(.keyword, "data class")])

        if !staticMembers.isEmpty, let bodyStart = tokens.firstIndex(where: { $0.value == "{"}) {
            let companionTokens = indent(tokenizeCompanion(staticMembers, node: declaration))
                .prefix(with: declaration.newToken(.linebreak, "\n"))
                .suffix(with: declaration.newToken(.linebreak, "\n"))
            tokens.insert(contentsOf: companionTokens, at: bodyStart + 1)
        }

        if !declarationMembers.isEmpty, let bodyStart = tokens.firstIndex(where: { $0.value == "{"}) {
            let linebreak = declaration.newToken(.linebreak, "\n")
            let declarationTokens: [Token]
            if declarationMembers.count == 1 {
                declarationTokens = declarationMembers
                        .flatMap { tokenize($0) }
            } else {
                let joinTokens = [
                    declaration.newToken(.delimiter, ","),
                    linebreak
                ]
                declarationTokens = indent(
                    declarationMembers
                        .map { tokenize($0) }
                        .joined(tokens: joinTokens))
                    .prefix(with: linebreak)
            }
            tokens.insert(contentsOf: declarationTokens
                .prefix(with: declaration.newToken(.startOfScope, "("))
                .suffix(with: declaration.newToken(.endOfScope, ")")),
                          at: bodyStart - 1)
        }

        return tokens
    }

    open override func tokenize(_ declaration: ProtocolDeclaration) -> [Token] {
        return super.tokenize(declaration)
            .replacing({ $0.value == "protocol"},
                       with: [declaration.newToken(.keyword, "interface")])
    }

    open override func tokenize(_ member: ProtocolDeclaration.PropertyMember, node: ASTNode) -> [Token] {
        let attrsTokens = tokenize(member.attributes, node: node)
        let modifiersTokens = tokenize(member.modifiers, node: node)

        return [
            attrsTokens,
            modifiersTokens,
            [member.newToken(.keyword, member.getterSetterKeywordBlock.setter == nil ? "val" : "var", node)],
            member.newToken(.identifier, member.name, node) + tokenize(member.typeAnnotation, node: node),
        ].joined(token: member.newToken(.space, " ", node))
    }

    open override func tokenize(_ modifier: AccessLevelModifier, node: ASTNode) -> [Token] {
        return [modifier.newToken(
            .keyword,
            modifier.rawValue.replacingOccurrences(of: "fileprivate", with: "private"),
            node)]
    }

    open override func tokenize(_ declaration: InitializerDeclaration) -> [Token] {
        var tokens = super.tokenize(declaration)

        // Find super.init and move to body start
        let superInitExpression = declaration.body.statements
            .compactMap { ($0 as? FunctionCallExpression)?.postfixExpression as? SuperclassExpression }
            .filter { $0.isInitializer }
            .first

        let selfInitExpression = declaration.body.statements
            .compactMap { ($0 as? FunctionCallExpression)?.postfixExpression as? SelfExpression }
            .filter { $0.isInitializer }
            .first

        let bodyStart = tokens.firstIndex(where: { $0.node === declaration.body })

        if  let bodyStart = bodyStart,
            let initExpression: ASTNode = superInitExpression ?? selfInitExpression,
            let superIndex = tokens.firstIndex(where: { $0.node === initExpression }),
            let endOfScopeIndex = tokens[superIndex...].firstIndex(where: { $0.kind == .endOfScope && $0.value == ")" }){
            let keyword = superInitExpression != nil ? "super" : "this"
            let superCallTokens = Array(tokens[superIndex...endOfScopeIndex])
                .replacing({ $0.node === initExpression }, with: [])
                .prefix(with: initExpression.newToken(.keyword, keyword))
                .prefix(with: initExpression.newToken(.space, " "))
                .prefix(with: initExpression.newToken(.symbol, ":"))
                .suffix(with: initExpression.newToken(.space, " "))

            tokens.removeSubrange((superIndex - 1)...(endOfScopeIndex + 1))
            tokens.insert(contentsOf: superCallTokens, at: bodyStart)
        }

        return tokens.replacing({ $0.value == "init"},
                                with: [declaration.newToken(.keyword, "constructor")])
    }

    open override func tokenize(_ modifier: DeclarationModifier, node: ASTNode) -> [Token] {
        switch modifier {
        case .static, .unowned, .unownedSafe, .unownedUnsafe, .weak, .convenience, .dynamic, .lazy:
            return []
        case .accessLevel(let mod) where mod.rawValue.contains("(set)"):
            return []
        default:
            return super.tokenize(modifier, node: node)
        }
    }

    open override func tokenize(_ declaration: ExtensionDeclaration) -> [Token] {
        let inheritanceTokens = declaration.typeInheritanceClause.map {
            self.unsupportedTokens(message: "Kotlin does not support inheritance clauses in extensions:  \($0)", element: $0, node: declaration)
        } ?? []
        let whereTokens = declaration.genericWhereClause.map {
            self.unsupportedTokens(message: "Kotlin does not support where clauses in extensions:  \($0)", element: $0, node: declaration)
        } ?? []
        let modifierTokens = declaration.accessLevelModifier.map { tokenize($0, node: declaration) }?
            .suffix(with: declaration.newToken(.space, " ")) ?? []
        let typeTokens = tokenize(declaration.type, node: declaration)

        let memberTokens = declaration.members.map { member in
            var tokens = tokenize(member)
            let firstToken = tokens.firstIndex(where: { $0.kind != .linebreak }) ?? 0
            tokens.insert(contentsOf: modifierTokens, at: firstToken)
            if let index = tokens.firstIndex(where: { $0.kind == .identifier }) {
                if member.isStatic {
                    tokens.insert(contentsOf: [declaration.newToken(.keyword, "Companion"), declaration.newToken(.delimiter, ".")], at: index)
                }
                tokens.insert(contentsOf: typeTokens + declaration.newToken(.delimiter, "."), at: index)
            }
            return tokens
        }.joined(token: declaration.newToken(.linebreak, "\n"))

        return [
            inheritanceTokens,
            whereTokens,
            memberTokens
        ].joined(token: declaration.newToken(.linebreak, "\n"))
    }
    
    open override func tokenize(_ declaration: VariableDeclaration) -> [Token] {
        let spaceToken = declaration.newToken(.space, " ")
        let mutabilityTokens = [declaration.newToken(.keyword, declaration.isReadOnly ? "val" : "var")]
        let attrsTokenGroups = declaration.attributes.map { tokenize($0, node: declaration) }
        var modifierTokenGroups = declaration.modifiers.map { tokenize($0, node: declaration) }
        var bodyTokens = tokenize(declaration.body, node: declaration)
        
        if declaration.isImplicitlyUnwrapped {
            modifierTokenGroups = [[declaration.newToken(.keyword, "lateinit")]] + modifierTokenGroups
        }
        
        if declaration.isOptional && declaration.initializerList?.last?.initializerExpression == nil {
                bodyTokens = bodyTokens + [
                    spaceToken,
                    declaration.newToken(.symbol, "="),
                    spaceToken,
                    declaration.newToken(.keyword, "null")
                ]
        } else if declaration.isLazy {
            bodyTokens = bodyTokens
                .replacing({ $0.value == " = " }, with: [
                    spaceToken,
                    declaration.newToken(.keyword, "by"),
                    spaceToken,
                    declaration.newToken(.keyword, "lazy"),
                    spaceToken,
                    ], amount: 1)
            if bodyTokens.last?.value == ")" {
                bodyTokens.removeLast()
            }
            if bodyTokens.last?.value == "(" {
                bodyTokens.removeLast()
            }
        }

        if declaration.isPrivateSet || declaration.isProtectedSet {
            let modifierToken = declaration.newToken(.keyword, declaration.isPrivateSet ? "private" : "protected")
            // If there is already a setter, change its accesibility
            if let setterIndex = bodyTokens.firstIndex(where: { $0.kind == .keyword && $0.value == "set" }) {
                bodyTokens.insert(contentsOf: [modifierToken, spaceToken], at: setterIndex)
            } else { // Else create modified setter
                bodyTokens.append(contentsOf:
                    [declaration.newToken(.linebreak, "\n")] +
                    indent([modifierToken, spaceToken, declaration.newToken(.keyword, "set")])
                )
            }
        }

        return [
            attrsTokenGroups.joined(token: spaceToken),
            modifierTokenGroups.joined(token: spaceToken),
            mutabilityTokens,
            bodyTokens
        ].joined(token: spaceToken)
    }

    open override func tokenize(_ body: VariableDeclaration.Body, node: ASTNode) -> [Token] {
        switch body {
        case let .codeBlock(name, typeAnnotation, codeBlock):
            let getterTokens = [
                body.newToken(.keyword, "get()", node),
                body.newToken(.space, " ", node)
            ]
            return body.newToken(.identifier, name, node) +
                tokenize(typeAnnotation, node: node) +
                body.newToken(.linebreak, "\n", node) +
                indent(
                    getterTokens +
                    tokenize(codeBlock)
                )
            
        case let .willSetDidSetBlock(name, typeAnnotation, initExpr, block):
            let newName = block.willSetClause?.name ?? .name("newValue")
            let oldName = block.didSetClause?.name ?? .name("oldValue")
            let fieldAssignmentExpression = AssignmentOperatorExpression(
                leftExpression: IdentifierExpression(kind: IdentifierExpression.Kind.identifier(.name("field"), nil)),
                rightExpression: IdentifierExpression(kind: IdentifierExpression.Kind.identifier(newName, nil))
            )
            let oldValueAssignmentExpression = ConstantDeclaration(initializerList: [
                PatternInitializer(pattern: IdentifierPattern(identifier: oldName),
                                   initializerExpression: IdentifierExpression(kind: IdentifierExpression.Kind.identifier(.name("field"), nil)))
            ])
            let setterCodeBlock = CodeBlock(statements:
                    (block.didSetClause?.codeBlock.statements.count ?? 0 > 0 ? [oldValueAssignmentExpression] : []) +
                    (block.willSetClause?.codeBlock.statements ?? []) +
                    [fieldAssignmentExpression] +
                    (block.didSetClause?.codeBlock.statements ?? [])
            )
            let setterTokens = tokenize(GetterSetterBlock.SetterClause(name: newName, codeBlock: setterCodeBlock), node: node)            
            let typeAnnoTokens = typeAnnotation.map { tokenize($0, node: node) } ?? []
            let initTokens = initExpr.map { body.newToken(.symbol, " = ", node) + tokenize($0) } ?? []
            return [
                body.newToken(.identifier, name, node)] +
                typeAnnoTokens +
                initTokens +
                [body.newToken(.linebreak, "\n", node)] +
                indent(setterTokens)
            
        default:
            return super.tokenize(body, node: node).removingTrailingSpaces()
        }
    }

    open override func tokenize(_ block: GetterSetterBlock, node: ASTNode) -> [Token] {
        let getterTokens = tokenize(block.getter, node: node)
            .replacing({ $0.kind == .keyword && $0.value == "get" }, with: [block.newToken(.keyword, "get()", node)])
        let setterTokens = block.setter.map { tokenize($0, node: node) } ?? []
        return [
            indent(getterTokens),
            indent(setterTokens),
        ].joined(token: block.newToken(.linebreak, "\n", node))
        .prefix(with: block.newToken(.linebreak, "\n", node))
    }

    open override func tokenize(_ block: GetterSetterBlock.SetterClause, node: ASTNode) -> [Token] {
        let newSetter = GetterSetterBlock.SetterClause(attributes: block.attributes,
                                                       mutationModifier: block.mutationModifier,
                                                       name: block.name ?? .name("newValue"),
                                                       codeBlock: block.codeBlock)        
        return super.tokenize(newSetter, node: node)
    }

    open override func tokenize(_ block: WillSetDidSetBlock, node: ASTNode) -> [Token] {
        let name = block.willSetClause?.name ?? block.didSetClause?.name ?? .name("newValue")
        let willSetBlock = block.willSetClause.map { tokenize($0.codeBlock) }?.tokensOnScope(depth: 1) ?? []
        let didSetBlock = block.didSetClause.map { tokenize($0.codeBlock) }?.tokensOnScope(depth: 1) ?? []
        let assignmentBlock = [
            block.newToken(.identifier, "field", node),
            block.newToken(.keyword, " = ", node),
            block.newToken(.identifier, name, node)
        ]
        return [
            [block.newToken(.startOfScope, "{", node)],
            willSetBlock,
            indent(assignmentBlock),
            didSetBlock,
            [block.newToken(.endOfScope, "}", node)]
        ].joined(token: block.newToken(.linebreak, "\n", node))
        
    }
    
    open override func tokenize(_ declaration: ImportDeclaration) -> [Token] {
        return []
    }
    
    open override func tokenize(_ declaration: EnumDeclaration) -> [Token] {
        let unionCases = declaration.members.compactMap { $0.unionStyleEnumCase }
        let simpleCases = unionCases.flatMap { $0.cases }
        let lineBreak = declaration.newToken(.linebreak, "\n")

        guard unionCases.count <= declaration.members.count && // unionCases is 0 when enums have specific values
            declaration.genericParameterClause == nil &&
            declaration.genericWhereClause == nil else {
                return self.unsupportedTokens(message: "Complex enums not supported yet", element: declaration, node: declaration).suffix(with: lineBreak) +
                    super.tokenize(declaration)
        }

        // Simple enums (no tuple values)
        if !simpleCases.contains(where: { $0.tuple != nil }) {
            if declaration.typeInheritanceClause != nil {
                return tokenizeSimpleValueEnum(declaration:declaration, simpleCases: simpleCases)
            } else {
                return tokenizeNoValueEnum(declaration: declaration, simpleCases: simpleCases)
            }
        }
        // Tuples or inhertance required sealed classes
        else {
            return tokenizeSealedClassEnum(declaration: declaration, simpleCases: simpleCases)
        }
    }
    
    open override func tokenize(_ codeBlock: CodeBlock) -> [Token] {
        guard codeBlock.statements.count == 1,
            let returnStatement = codeBlock.statements.first as? ReturnStatement,
            let parent = codeBlock.lexicalParent as? Declaration else {
            return super.tokenize(codeBlock)
        }
        let sameLine = parent is VariableDeclaration
        let separator = sameLine ? codeBlock.newToken(.space, " ") : codeBlock.newToken(.linebreak, "\n")
        let tokens = Array(tokenize(returnStatement).dropFirst(2))
        return [
            [codeBlock.newToken(.symbol, "=")],
            sameLine ? tokens : indent(tokens)
        ].joined(token: separator)
    }
    
    // MARK: - Statements

    open override func tokenize(_ statement: GuardStatement) -> [Token] {
        let declarationTokens = tokenizeDeclarationConditions(statement.conditionList, node: statement)
        if statement.isUnwrappingGuard, let body = statement.codeBlock.statements.first {
            return [
                Array(declarationTokens.dropLast()),
                [statement.newToken(.symbol, "?:")],
                tokenize(body),
            ].joined(token: statement.newToken(.space, " "))
        } else {
            let invertedConditions = statement.conditionList.map(InvertedCondition.init)
            return declarationTokens + [
                [statement.newToken(.keyword, "if")],
                tokenize(invertedConditions, node: statement),
                tokenize(statement.codeBlock)
            ].joined(token: statement.newToken(.space, " "))
        }
    }

    open override func tokenize(_ statement: IfStatement) -> [Token] {
        return tokenizeDeclarationConditions(statement.conditionList, node: statement) +
            super.tokenize(statement)
    }

    open override func tokenize(_ statement: SwitchStatement) -> [Token] {
        var casesTokens = statement.newToken(.startOfScope, "{") + statement.newToken(.endOfScope, "}")
        if !statement.cases.isEmpty {
            casesTokens = [
                [statement.newToken(.startOfScope, "{")],
                indent(
                    statement.cases.map { tokenize($0, node: statement) }
                    .joined(token: statement.newToken(.linebreak, "\n"))),
                [statement.newToken(.endOfScope, "}")]
                ].joined(token: statement.newToken(.linebreak, "\n"))
        }

        return [
            [statement.newToken(.keyword, "when")],
            tokenize(statement.expression)
                .prefix(with: statement.newToken(.startOfScope, "("))
                .suffix(with: statement.newToken(.endOfScope, ")")),
            casesTokens
            ].joined(token: statement.newToken(.space, " "))
    }

    open override func tokenize(_ statement: SwitchStatement.Case, node: ASTNode) -> [Token] {
        let separatorTokens =  [
            statement.newToken(.space, " ", node),
            statement.newToken(.delimiter, "->", node),
            statement.newToken(.space, " ", node),
        ]
        switch statement {
        case let .case(itemList, stmts):
            let prefix = itemList.count > 1 ? [statement.newToken(.keyword, "in", node), statement.newToken(.space, " ", node)] : []
            let conditions = itemList.map { tokenize($0, node: node) }.joined(token: statement.newToken(.delimiter, ", ", node))
            var statements = tokenize(stmts, node: node)
            if stmts.count > 1 || statements.filter({ $0.kind == .linebreak }).count > 1 {
                let linebreak = statement.newToken(.linebreak, "\n", node)
                statements = [statement.newToken(.startOfScope, "{", node), linebreak] +
                    indent(statements) +
                    [linebreak, statement.newToken(.endOfScope, "}", node)]
            }
            return prefix + conditions + separatorTokens + statements

        case .default(let stmts):
            return
                [statement.newToken(.keyword, "else", node)] +
                    separatorTokens +
                    tokenize(stmts, node: node)
        }
    }

    open override func tokenize(_ statement: SwitchStatement.Case.Item, node: ASTNode) -> [Token] {
        guard let enumCasePattern = statement.pattern as? EnumCasePattern else {
            return super.tokenize(statement, node: node)
        }
        let patternWithoutTuple = EnumCasePattern(typeIdentifier: enumCasePattern.typeIdentifier, name: enumCasePattern.name, tuplePattern: nil)
        return [
            tokenize(patternWithoutTuple, node: node),
            statement.whereExpression.map { _ in [statement.newToken(.keyword, "where", node)] } ?? [],
            statement.whereExpression.map { tokenize($0) } ?? []
            ].joined(token: statement.newToken(.space, " ", node))
    }


    open override func tokenize(_ statement: ForInStatement) -> [Token] {
        var tokens = super.tokenize(statement)
        if let endIndex = tokens.firstIndex(where: { $0.value == "{"}) {
            tokens.insert(statement.newToken(.endOfScope, ")"), at: endIndex - 1)
            tokens.insert(statement.newToken(.startOfScope, "("), at: 2)
        }
        return tokens
    }

    // MARK: - Expressions
    open override func tokenize(_ expression: ExplicitMemberExpression) -> [Token] {
        switch expression.kind {
        case let .namedType(postfixExpr, identifier):
            let postfixTokens = tokenize(postfixExpr)
            var delimiters = [expression.newToken(.delimiter, ".")]

            if postfixTokens.last?.value != "?" &&
                postfixTokens.removingOtherScopes().contains(where: {
                    $0.value == "?" && $0.origin is OptionalChainingExpression
                }) {
                delimiters = delimiters.prefix(with: expression.newToken(.symbol, "?"))
            }
            return postfixTokens + delimiters + expression.newToken(.identifier, identifier)
        default:
            return super.tokenize(expression)
        }
    }

    open override func tokenize(_ expression: AssignmentOperatorExpression) -> [Token] {
        guard expression.leftExpression is WildcardExpression else {
            return super.tokenize(expression)
        }
        return tokenize(expression.rightExpression)
    }

    open override func tokenize(_ expression: LiteralExpression) -> [Token] {
        switch expression.kind {
        case .nil:
            return [expression.newToken(.keyword, "null")]
        case let .interpolatedString(_, rawText):
            return tokenizeInterpolatedString(rawText, node: expression)
        case let .staticString(_, rawText):
            return [expression.newToken(.string, conversionUnicodeString(rawText, node: expression))]
        case .array(let exprs):
            let isGenericTypeInfo = expression.lexicalParent is FunctionCallExpression
            return
                expression.newToken(.identifier, "listOf") +
                    expression.newToken(.startOfScope, isGenericTypeInfo ? "<" : "(") +
                exprs.map { tokenize($0) }.joined(token: expression.newToken(.delimiter, ", ")) +
                    expression.newToken(.endOfScope, isGenericTypeInfo ? ">" : ")")
        case .dictionary(let entries):
            let isGenericTypeInfo = expression.lexicalParent is FunctionCallExpression
            var entryTokens = entries.map { tokenize($0, node: expression) }.joined(token: expression.newToken(.delimiter, ", "))
            if isGenericTypeInfo {
                entryTokens = entryTokens.replacing({ $0.value == "to"}, with: [expression.newToken(.delimiter, ",") ])
            }
            return [expression.newToken(.identifier, "mapOf"),
                expression.newToken(.startOfScope, isGenericTypeInfo ? "<" : "(")] +
                entryTokens +
                [expression.newToken(.endOfScope, isGenericTypeInfo ? ">" : ")")]
        default:
            return super.tokenize(expression)
        }
    }

    open override func tokenize(_ entry: DictionaryEntry, node: ASTNode) -> [Token] {
        return tokenize(entry.key) +
            entry.newToken(.space, " ", node) +
            entry.newToken(.keyword, "to", node) +
            entry.newToken(.space, " ", node) +
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
        let binaryOperator: Operator
        switch expression.binaryOperator {
        case "..<": binaryOperator = "until"
        case "...": binaryOperator = ".."
        case "??": binaryOperator = "?:"
        default: binaryOperator = expression.binaryOperator
        }
        return super.tokenize(expression)
            .replacing({ $0.kind == .symbol && $0.value == expression.binaryOperator },
                       with: [expression.newToken(.symbol, binaryOperator)])
    }

    open override func tokenize(_ expression: FunctionCallExpression) -> [Token] {
        var tokens = super.tokenize(expression)
        if (expression.postfixExpression is OptionalChainingExpression || expression.postfixExpression is ForcedValueExpression),
            let startIndex = tokens.indexOf(kind: .startOfScope, after: 0) {
            tokens.insert(contentsOf: [
                expression.newToken(.symbol, "."),
                expression.newToken(.keyword, "invoke")
            ], at: startIndex)
        }
        return tokens
    }
    
    open override func tokenize(_ expression: FunctionCallExpression.Argument, node: ASTNode) -> [Token] {
        return super.tokenize(expression, node: node)
            .replacing({ $0.value == ": " && $0.kind == .delimiter },
                       with: [expression.newToken(.delimiter, " = ", node)])
    }

    open override func tokenize(_ expression: ClosureExpression) -> [Token] {
        var tokens = super.tokenize(expression)
        if expression.signature != nil {
            let arrowTokens = expression.signature?.parameterClause != nil ? [expression.newToken(.symbol, " -> ")] : []
            tokens = tokens.replacing({ $0.value == "in" },
                                      with: arrowTokens,
                                      amount: 1)
        }
        
        // Last return can be removed
        if let lastReturn = expression.statements?.last as? ReturnStatement,
            let index = tokens.firstIndex(where: { $0.node === lastReturn && $0.value == "return" }) {
            tokens.remove(at: index)
            tokens.remove(at: index)
        }
        
        // Other returns must be suffixed with call name
        if let callExpression = expression.lexicalParent as? FunctionCallExpression,
            let memberExpression = callExpression.postfixExpression as? ExplicitMemberExpression {
            while let returnIndex = tokens.firstIndex(where: { $0.value == "return" }) {
                tokens.remove(at: returnIndex)
                tokens.insert(expression.newToken(.keyword, "return@"), at: returnIndex)
                tokens.insert(expression.newToken(.identifier, memberExpression.identifier), at: returnIndex + 1)
            }
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

    open override func tokenize(_ expression: ForcedValueExpression) -> [Token] {
        return tokenize(expression.postfixExpression) + expression.newToken(.symbol, "!!")
    }

    open override func tokenize(_ expression: TernaryConditionalOperatorExpression) -> [Token] {
        return [
            [expression.newToken(.keyword, "if")],
            tokenize(expression.conditionExpression)
                .prefix(with: expression.newToken(.startOfScope, "("))
                .suffix(with: expression.newToken(.endOfScope, ")")),
            tokenize(expression.trueExpression),
            [expression.newToken(.keyword, "else")],
            tokenize(expression.falseExpression),
            ].joined(token: expression.newToken(.space, " "))
    }


    open override func tokenize(_ expression: SequenceExpression) -> [Token] {
        var elementTokens = expression.elements.map({ tokenize($0, node: expression) })

        //If there is a ternary, then prefix with if
        if let ternaryOperatorIndex = expression.elements.firstIndex(where: { $0.isTernaryConditionalOperator }),
            ternaryOperatorIndex > 0 {
            let assignmentIndex = expression.elements.firstIndex(where: { $0.isAssignmentOperator }) ?? -1
            let prefixTokens = [
                expression.newToken(.keyword, "if"),
                expression.newToken(.space, " "),
                expression.newToken(.startOfScope, "("),
            ]
            elementTokens[assignmentIndex + 1] =
                prefixTokens +
                elementTokens[assignmentIndex + 1]
            elementTokens[ternaryOperatorIndex - 1] = elementTokens[ternaryOperatorIndex - 1]
                .suffix(with: expression.newToken(.endOfScope, ")"))
        }
        return elementTokens.joined(token: expression.newToken(.space, " "))
    }

    open override func tokenize(_ element: SequenceExpression.Element, node: ASTNode) -> [Token] {
        switch element {
        case .ternaryConditionalOperator(let expr):
            return [
                tokenize(expr),
                [node.newToken(.keyword, "else")],
                ].joined(token: node.newToken(.space, " "))
        default:
            return super.tokenize(element, node: node)
        }
    }

    open override func tokenize(_ expression: OptionalChainingExpression) -> [Token] {
        var tokens = tokenize(expression.postfixExpression)
        if tokens.last?.value != "this" {
            tokens.append(expression.newToken(.symbol, "?"))
        }
        return tokens
    }

    open override func tokenize(_ expression: TypeCastingOperatorExpression) -> [Token] {
        switch expression.kind {
        case let .forcedCast(expr, type):
            return [
                tokenize(expr),
                [expression.newToken(.keyword, "as")],
                tokenize(type, node: expression)
            ].joined(token: expression.newToken(.space, " "))
        default:
            return super.tokenize(expression)
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
        return type.newToken(.identifier, typeMap[type.name.textDescription] ?? type.name.textDescription, node) +
            type.genericArgumentClause.map { tokenize($0, node: node) }
    }

    open override func tokenize(_ type: ImplicitlyUnwrappedOptionalType, node: ASTNode) -> [Token] {
        return tokenize(type.wrappedType, node: node)
    }

    open override func tokenize(_ attribute: Attribute, node: ASTNode) -> [Token] {
        if ["escaping", "autoclosure", "discardableResult"].contains(attribute.name.textDescription) {
            return []
        }
        return super.tokenize(attribute, node: node)
    }

    open override func tokenize(_ type: TupleType, node: ASTNode) -> [Token] {
        var typeWithNames = [TupleType.Element]()

        for (index, element) in type.elements.enumerated() {
            if element.name != nil || element.type is FunctionType {
                typeWithNames.append(element)
            } else {
                typeWithNames.append(TupleType.Element(type: element.type, name: .name("v\(index + 1)"), attributes: element.attributes, isInOutParameter: element.isInOutParameter))
            }
        }
        return type.newToken(.startOfScope, "(", node) +
            typeWithNames.map { tokenize($0, node: node) }.joined(token: type.newToken(.delimiter, ", ", node)) +
            type.newToken(.endOfScope, ")", node)
    }

    open override func tokenize(_ type: TupleType.Element, node: ASTNode) -> [Token] {
        var nameTokens = [Token]()
        if let name = type.name {
            nameTokens = type.newToken(.keyword, "val", node) +
                type.newToken(.space, " ", node) +
                type.newToken(.identifier, name, node) +
                type.newToken(.delimiter, ":", node)
        }
        return [
            nameTokens,
            tokenize(type.attributes, node: node),
            tokenize(type.type, node: node)
        ].joined(token: type.newToken(.space, " ", node))
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

    open override func tokenize(_ origin: ThrowsKind, node: ASTNode) -> [Token] {
        return []
    }

    open func unsupportedTokens(message: String, element: ASTTokenizable, node: ASTNode) -> [Token] {
        return [element.newToken(.comment, "//FIXME: @SwiftKotlin - \(message)", node)]
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
        if case Condition.expression(let expression) = condition.condition, expression is ParenthesizedExpression {
            return tokens.prefix(with: condition.condition.newToken(.symbol, "!", node))
        } else {
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


    private func tokenizeCompanion(_ members: [StructDeclaration.Member], node: ASTNode) -> [Token] {
        return tokenizeCompanion(members.compactMap { $0.declaration }, node: node)
    }

    private func tokenizeCompanion(_ members: [ClassDeclaration.Member], node: ASTNode) -> [Token] {
        return tokenizeCompanion(members.compactMap { $0.declaration }, node: node)
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

    private func conversionUnicodeString(_ rawText:String, node:ASTNode) -> String {
        var remainingText = rawText
        var unicodeString = ""

        while let startRange = remainingText.range(of: "u{") {
            unicodeString += remainingText[..<startRange.lowerBound] + "u"
            remainingText = String(remainingText[startRange.upperBound...])

            var scopes = 1
            var i = 1
            while i < remainingText.count && scopes > 0 {
                let index = remainingText.index(remainingText.startIndex, offsetBy: i)
                i += 1
                switch remainingText[index] {
                case "}": scopes -= 1
                default: continue
                }
            }

            unicodeString += remainingText[..<remainingText.index(remainingText.startIndex, offsetBy: i - 1)]
            remainingText = String(remainingText[remainingText.index(remainingText.startIndex, offsetBy: i)...])
        }

        unicodeString += remainingText
        return unicodeString
    }

    private func tokenizeInterpolatedString(_ rawText: String, node: ASTNode) -> [Token] {
        var remainingText = conversionUnicodeString(rawText, node: node)
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
            let computedExpression = translate(content: expression).tokens?.joinedValues().replacingOccurrences(of: "\n", with: "")
            
            interpolatedString += "${\(computedExpression ?? expression)}"
            remainingText = String(remainingText[remainingText.index(remainingText.startIndex, offsetBy: i)...])
        }

        interpolatedString += remainingText
        return [node.newToken(.string, interpolatedString)]
    }

    // function used to remove default arguments from override functions, since kotlin doesn't have them
    private func removeDefaultArgsFromParameters(tokens:[Token]) -> [Token] {
        var newTokens = [Token]()
        var removing = false
        var bracket = false
        for t in tokens {
            if removing && t.kind == .startOfScope && t.value == "(" {
                bracket = true
            }
            if bracket && t.kind == .endOfScope && t.value == ")" {
                bracket = false
                removing = false
                continue
            }
            if t.kind == .symbol && (t.value.contains("=")) {
                removing = true
            }
            if t.kind == .delimiter && t.value.contains(",") {
                removing = false
            }
            if !bracket && removing && t.kind == .endOfScope && t.value == ")" {
                removing = false
            }
            if !removing {
                newTokens.append(t)
            }
        }
        return newTokens
    }
    
}

public typealias InvertedConditionList = [InvertedCondition]
public struct InvertedCondition: ASTTokenizable {
    public let condition: Condition
}
