//
//  TransformPlugin.swift
//  SwiftKotlinPackageDescription
//
//  Created by Angel Luis Garcia on 14/10/2017.
//

import Foundation
import Transform
import AST

public protocol TransformPlugin {
    var name: String { get }
    var description: String { get }
}

public protocol SourceTransformPlugin: TransformPlugin {
    func transform(source: String) throws -> String
}

public protocol TokenTransformPlugin: TransformPlugin {
    func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token]
}
