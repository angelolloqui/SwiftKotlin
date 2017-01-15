//
//  KeywordReplacementTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation


class KeywordReplacementTransformer: Transformer {
    let replacementKeywordMap = [
        "protocol": "interface",
        "let": "val",
        "func": "fun",
        "fileprivate": "private"
    ]
    
    let replacementIndetifierMap = [
        "self": "this",
        "$0": "it",
        "nil": "null",
    ]
    
    let replacementSymbolMap = [
        "??": "?:",
        "...": ".."
    ]
    
    func transform(formatter: Formatter) throws {
        formatter.forEachToken { (i, token) in
            let replace: String?
            switch token {
            case .keyword(let string):
                replace = self.replacementKeywordMap[string]
            case .identifier(let string):
                replace = self.replacementIndetifierMap[string]
            case .symbol(let string, _):
                replace = self.replacementSymbolMap[string]
            default:
                replace = nil
            }
            if let replace = replace {
                formatter.replaceToken(at: i, with: token.with(string: replace))
            }
        }
    }
}
