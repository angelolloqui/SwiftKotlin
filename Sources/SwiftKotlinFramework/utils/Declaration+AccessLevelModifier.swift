//
//  Declaration+AccessLevelModifier.swift
//  AST
//
//  Created by Angel Luis Garcia on 19/06/2020.
//

import Transform
import AST

extension KotlinTokenizer {
    func changeAccessLevelModifier(_ declaration: Declaration) -> Declaration {
        // If explicit, use it otherwise check parent's
        if let accessLevel = declaration.accessLevelModifier {
            return declaration.copyWith(accessLevelModifier: accessLevel.toKotlin())
        }
        //Extension and protocol members get automatic access level from parent
        if declaration.lexicalParent is ExtensionDeclaration || declaration.lexicalParent is ProtocolDeclaration {
            return declaration.copyWith(accessLevelModifier: declaration.lexicalParentAccessLevelModifier?.toKotlin())
        }
        if declaration.lexicalParentAccessLevelModifier?.toKotlin() != nil {
            return declaration
        }
        return declaration.copyWith(accessLevelModifier: .internal)
    }
}

private extension AccessLevelModifier {
    func toKotlin() -> AccessLevelModifier? {
        switch self {
        case .private, .fileprivate:
            return .private
        case .internal:
            return .internal
        case .public:
            return nil
        case .open:
            return .open
        default:
            return self
        }
    }
}

private extension Declaration {
    func copyWith(accessLevelModifier: AccessLevelModifier?) -> Declaration {
        guard accessLevelModifier != self.accessLevelModifier else { return self }
        guard let parent = (self as? ASTNode)?.lexicalParent, parent is CodeBlock != true, parent is ClosureExpression != true else { return self }
        let copy: Declaration
        switch self {
        case let decl as ClassDeclaration:
            copy = ClassDeclaration(
                attributes: decl.attributes,
                accessLevelModifier: accessLevelModifier,
                isFinal: decl.isFinal,
                name: decl.name,
                genericParameterClause: decl.genericParameterClause,
                typeInheritanceClause: decl.typeInheritanceClause,
                genericWhereClause: decl.genericWhereClause,
                members: decl.members
            )
        case let decl as ConstantDeclaration:
            copy = ConstantDeclaration(
                attributes: decl.attributes,
                modifiers: decl.modifiers.replacing(accessLevelModifier: accessLevelModifier),
                initializerList: decl.initializerList
            )
        case let decl as EnumDeclaration:
            copy = EnumDeclaration(
                attributes: decl.attributes,
                accessLevelModifier: accessLevelModifier,
                isIndirect: decl.isIndirect,
                name: decl.name,
                genericParameterClause: decl.genericParameterClause,
                typeInheritanceClause: decl.typeInheritanceClause,
                genericWhereClause: decl.genericWhereClause,
                members: decl.members
            )
        case let decl as ExtensionDeclaration:
            copy = ExtensionDeclaration(
                attributes: decl.attributes,
                accessLevelModifier: accessLevelModifier,
                type: decl.type,
                genericWhereClause: decl.genericWhereClause,
                members: decl.members
            )
        case let decl as FunctionDeclaration:
            copy = FunctionDeclaration(
                attributes: decl.attributes,
                modifiers: decl.modifiers.replacing(accessLevelModifier: accessLevelModifier),
                name: decl.name,
                genericParameterClause: decl.genericParameterClause,
                signature: decl.signature,
                genericWhereClause: decl.genericWhereClause,
                body: decl.body
            )
        case let decl as InitializerDeclaration:
            copy = InitializerDeclaration(
                attributes: decl.attributes,
                modifiers: decl.modifiers.replacing(accessLevelModifier: accessLevelModifier),
                kind: decl.kind,
                genericParameterClause: decl.genericParameterClause,
                parameterList: decl.parameterList,
                throwsKind: decl.throwsKind,
                genericWhereClause: decl.genericWhereClause,
                body: decl.body
            )
        case let decl as ProtocolDeclaration:
            copy = ProtocolDeclaration(
                attributes: decl.attributes,
                accessLevelModifier: accessLevelModifier,
                name: decl.name,
                typeInheritanceClause: decl.typeInheritanceClause,
                members: decl.members
            )
        case let decl as StructDeclaration:
            copy = StructDeclaration(
                attributes: decl.attributes,
                accessLevelModifier: accessLevelModifier,
                name: decl.name,
                genericParameterClause: decl.genericParameterClause,
                typeInheritanceClause: decl.typeInheritanceClause,
                genericWhereClause: decl.genericWhereClause,
                members: decl.members
            )
        case let decl as TypealiasDeclaration:
            copy = TypealiasDeclaration(
                attributes: decl.attributes,
                accessLevelModifier: accessLevelModifier,
                name: decl.name,
                generic: decl.generic,
                assignment: decl.assignment
            )
        case let decl as VariableDeclaration:
            copy = VariableDeclaration(
                attributes: decl.attributes,
                modifiers: decl.modifiers.replacing(accessLevelModifier: accessLevelModifier),
                initializerList: []
            )
            (copy as? VariableDeclaration)?.replaceBody(with: decl.body)
        default:
            copy = self
        }
        if let copy = copy as? ASTNode {
            lexicalParent.map(copy.setLexicalParent)
            copy.setSourceRange(sourceRange)
        }
        return copy
    }
}

extension Declaration {
    var accessLevelModifier: AccessLevelModifier? {
        switch self {
        case let decl as ClassDeclaration:
            return decl.accessLevelModifier
        case let decl as ConstantDeclaration:
            return decl.modifiers.accessLevelModifier
        case let decl as EnumDeclaration:
            return decl.accessLevelModifier
        case let decl as ExtensionDeclaration:
            return decl.accessLevelModifier
        case let decl as FunctionDeclaration:
            return decl.modifiers.accessLevelModifier
        case let decl as InitializerDeclaration:
            return decl.modifiers.accessLevelModifier
        case let decl as ProtocolDeclaration:
            return decl.accessLevelModifier
        case let decl as StructDeclaration:
            return decl.accessLevelModifier
        case let decl as SubscriptDeclaration:
            return decl.modifiers.accessLevelModifier
        case let decl as TypealiasDeclaration:
            return decl.accessLevelModifier
        case let decl as VariableDeclaration:
            return decl.modifiers.accessLevelModifier
        default:
            return nil
        }
    }

    var lexicalParentAccessLevelModifier: AccessLevelModifier? {
        var parent = lexicalParent
        while parent != nil {
            if let declaration = parent as? Declaration, let accessLevelModifier = declaration.accessLevelModifier {
                return accessLevelModifier
            }
            parent = parent?.lexicalParent
        }
        return nil
    }
}

private extension Collection where Iterator.Element == DeclarationModifier {
    var accessLevelModifier: AccessLevelModifier? {
        return self.compactMap { $0.accessLevelModifier }.first
    }
    func replacing(accessLevelModifier: AccessLevelModifier?) -> [DeclarationModifier] {
        var modifiers = self.filter { $0.accessLevelModifier == nil }
        if let accessLevelModifier = accessLevelModifier {
            modifiers.insert(DeclarationModifier.accessLevel(accessLevelModifier), at: 0)
        }
        return modifiers
    }
}

private extension DeclarationModifier {
    var accessLevelModifier: AccessLevelModifier? {
        switch self {
        case .accessLevel(let accessLevel):
            return accessLevel
        default:
            return nil
        }
    }
}
