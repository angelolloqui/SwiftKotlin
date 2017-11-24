//
//  TokenizationResult.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 24/11/2017.
//

import Source
import Diagnostic
import Transform

public struct TokenizationResult {
    public let sourceFile: SourceFile
    public let diagnostics: [Diagnostic]
    public let tokens: [Token]?
    public let exception: Error?
}
