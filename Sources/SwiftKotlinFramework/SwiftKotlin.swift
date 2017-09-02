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
}

public class KotlinTokenizer: Tokenizer {
    public init() {
    }


    public override func tokenize(_ declaration: StructDeclaration) -> [Token] {
        return super.tokenize(declaration) +
            [declaration.newToken(.comment, "//Works")]
    }
}

