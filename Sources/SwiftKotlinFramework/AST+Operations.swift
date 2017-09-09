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
}

extension FunctionDeclaration {
    var isStatic: Bool {
        return modifiers.isStatic
    }
}

extension StructDeclaration.Member {
    var isStatic: Bool {
        guard case .declaration(let declaration) = self else { return false }
        if let variable = declaration as? VariableDeclaration {
            return variable.isStatic
        }
        if let function = declaration as? FunctionDeclaration {
            return function.isStatic
        }
        return false
    }
}

extension ClassDeclaration.Member {
    var isStatic: Bool {
        guard case .declaration(let declaration) = self else { return false }
        if let variable = declaration as? VariableDeclaration {
            return variable.isStatic
        }
        if let function = declaration as? FunctionDeclaration {
            return function.isStatic
        }
        return false
    }
}

extension Collection where Iterator.Element == DeclarationModifier {
    var isStatic: Bool {
        return self.contains(where: { $0.isStatic })
    }
}

extension DeclarationModifier {
    var isStatic: Bool {
        switch self {
        case .`static`: return true
        default: return false
        }
    }
}
