//
//  AST+Operations.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 09/09/2017.
//

import AST

extension VariableDeclaration {
    var isStatic: Bool {
        return modifiers.isStatic
    }

    var isImplicitlyUnwrapped: Bool {
        return typeAnnotation?.type is ImplicitlyUnwrappedOptionalType
    }
    
    var isOptional: Bool {
        return typeAnnotation?.type is OptionalType
    }

    var isReadOnly: Bool {
        switch body {
        case .codeBlock: return true
        case .getterSetterBlock(_, _, let block) where block.setter == nil: return true
        default: return isLazy
        }
    }
    
    var isLazy: Bool {
        return modifiers.isLazy
    }

    var isPrivateSet: Bool {
        return modifiers.isPrivateSet
    }

    var isProtectedSet: Bool {
        return modifiers.isProtectedSet
    }

    var typeAnnotation: TypeAnnotation? {
        return initializerList?
            .compactMap { $0.pattern as? IdentifierPattern }
            .compactMap { $0.typeAnnotation }
            .first
    }
    
    var initializerList: [PatternInitializer]? {
        switch body {
        case .initializerList(let patterns):
            return patterns
        default:
            return nil
        }
    }
    
}

extension FunctionDeclaration {
    var isStatic: Bool {
        return modifiers.isStatic
    }
    var isOverride: Bool {
        return modifiers.isOverride
    }
}

extension StructDeclaration.Member {
    var isStatic: Bool {
        guard let declaration = self.declaration else { return false }
        if let variable = declaration as? VariableDeclaration {
            return variable.isStatic
        }
        if let function = declaration as? FunctionDeclaration {
            return function.isStatic
        }
        return false
    }

    var declaration: Declaration? {
        guard case .declaration(let declaration) = self else { return nil }
        return declaration
    }
}

extension ClassDeclaration.Member {
    var isStatic: Bool {
        guard let declaration = self.declaration else { return false }
        if let variable = declaration as? VariableDeclaration {
            return variable.isStatic
        }
        if let function = declaration as? FunctionDeclaration {
            return function.isStatic
        }
        return false
    }

    var declaration: Declaration? {
        guard case .declaration(let declaration) = self else { return nil }
        return declaration
    }
}

extension ExtensionDeclaration.Member {
    var isStatic: Bool {
        guard let declaration = self.declaration else { return false }
        if let variable = declaration as? VariableDeclaration {
            return variable.isStatic
        }
        if let function = declaration as? FunctionDeclaration {
            return function.isStatic
        }
        return false
    }

    var declaration: Declaration? {
        guard case .declaration(let declaration) = self else { return nil }
        return declaration
    }
}

extension Collection where Iterator.Element == DeclarationModifier {
    var isStatic: Bool {
        return self.contains(where: { $0.isStatic })
    }
    
    var isLazy: Bool {
        return self.contains(where: { $0.isLazy })
    }

    var isPrivateSet: Bool {
        return self.contains(where: { $0.isPrivateSet })
    }

    var isProtectedSet: Bool {
        return self.contains(where: { $0.isProtectedSet })
    }

    var isOverride: Bool {
        return self.contains(where: { $0.isOverride })
    }
}

extension DeclarationModifier {
    var isStatic: Bool {
        switch self {
        case .`static`: return true
        default: return false
        }
    }
    
    var isLazy: Bool {
        switch self {
        case .lazy: return true
        default: return false
        }
    }

    var isOverride: Bool {
        switch self {
        case .override: return true
        default: return false
        }
    }

    var isPrivateSet: Bool {
        switch self {
        case .accessLevel(let modifier):
            return modifier == .fileprivateSet || modifier == .privateSet
        default: return false
        }
    }

    var isProtectedSet: Bool {
        switch self {
        case .accessLevel(let modifier):
            return modifier == .openSet || modifier == .internalSet
        default: return false
        }
    }
}

extension SuperclassExpression {
    var isInitializer: Bool {
        switch kind {
        case .initializer:
            return true
        default:
            return false
        }
    }
}

extension SelfExpression {
    var isInitializer: Bool {
        switch kind {
        case .initializer:
            return true
        default:
            return false
        }
    }
}

extension ExplicitMemberExpression {
    var identifier: String {
        switch kind {
        case let .tuple(_, index):
            return "var\(index)"
        case let .namedType(_, identifier):
            return identifier.textDescription
        case let .generic(_, identifier, _):
            return identifier.textDescription
        case let .argument(_, identifier, _):
            return identifier.textDescription
        }
    }
}

extension EnumDeclaration.Member {
    
    var unionStyleEnumCase: EnumDeclaration.UnionStyleEnumCase? {
        switch self {
        case .union(let enumCase):
            return enumCase
        default:
            return nil
        }
    }
}

extension SequenceExpression.Element {
    var isTernaryConditionalOperator: Bool {
        switch self {
        case .ternaryConditionalOperator:
            return true
        default:
            return false
        }
    }
    var isAssignmentOperator: Bool {
        switch self {
        case .assignmentOperator:
            return true
        default:
            return false
        }
    }
}

extension Condition {
    var isUnwrappingCondition: Bool {
        switch self {
        case .let, .var:
            return true
        default:
            return false
        }
    }
}

extension GuardStatement {
    var isUnwrappingGuard: Bool {
        guard conditionList.count == 1,
            codeBlock.statements.count == 1,
            let condition = conditionList.first,
            let bodyStatement = codeBlock.statements.first
            else { return false }

        return condition.isUnwrappingCondition &&
            (bodyStatement is ReturnStatement || bodyStatement is ThrowStatement)
    }
}
