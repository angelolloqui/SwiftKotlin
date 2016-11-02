//
//  KeywordReplacementTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation


class KeywordReplacementTransformer: Transformer {
    let replacementIndetifierMap = [
        "protocol": "interface",
        "let": "val",
        "func": "fun",
        "self": "this",
        "$0": "it",
        "nil": "null",
    ]
    
    let replacementSymbolMap = [
        "??": "?:"
    ]
    
    func transform(formatter: Formatter) throws {
        formatter.forEachToken(ofType: .identifier) { (i, token) in
            guard let replace = self.replacementIndetifierMap[token.string] else { return }
            formatter.replaceTokenAtIndex(i, with: Token(token.type, replace))
        }
        formatter.forEachToken(ofType: .symbol) { (i, token) in
            guard let replace = self.replacementSymbolMap[token.string] else { return }
            formatter.replaceTokenAtIndex(i, with: Token(token.type, replace))
        }
    }
}
