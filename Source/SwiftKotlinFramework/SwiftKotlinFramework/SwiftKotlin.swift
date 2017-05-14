//
//  SwiftKotlin.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 14/09/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

protocol Transformer {
    func transform(formatter: Formatter, options: TransformOptions?) throws
}

class SwiftKotlin {
    let transformers: [Transformer]
    
    init(transformers: [Transformer]) {
        self.transformers = transformers
    }
    
    convenience init() {
        self.init(transformers: [
                ConditionalCompilationTransformer(),
                FunctionParametersTransformer(),
                ConstructorTransformer(), 
                ControlFlowTransformer(),
                PropertyTransformer(),
                StaticTransformer(),
                ExtensionTransformer(),
                StructTransformer(),
                StringInterpolatorTransformer(),
                KeywordReplacementTransformer(),
                FoundationTypeTransformer()
        ])
    }
    
    func translate(content: String, options: TransformOptions? = nil) throws -> String {
        let tokens = try translate(tokens: tokenize(content))
        return tokens.reduce("", { $0 + $1.string })
    }
    
    func translate(tokens: [Token], options: TransformOptions? = nil) throws -> [Token] {
        let formatter = Formatter(tokens)
        try transformers.forEach {
            try $0.transform(formatter: formatter, options: options)
        }
        return formatter.tokens
    }

}


