//
//  PluginDefinitions.swift
//  SwiftKotlinPackageDescription
//
//  Created by Angel Luis Garcia on 14/10/2017.
//

import Foundation
import Transform
import AST

public protocol SourceTransformPlugin {
    func transform(source: String) throws -> String
}

public protocol TokenTransformPlugin {
    func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token]
}
