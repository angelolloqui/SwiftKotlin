//
//  CotrolFlowTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 01/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

class ControlFlowTransformer: Transformer {
    let conditionals = [
        "if",
        "while",
        "for",
        "switch"
    ]
    
    func transform(formatter: Formatter) throws {
        addParenthesis(formatter)
        transformIfLetStatement(formatter)
        transformSwitch(formatter)
    }
    
    func addParenthesis(_ formatter: Formatter) {
        
        formatter.forEachToken(ofType: .identifier) { (i, token) in
            guard conditionals.contains(token.string) else { return }
            if  let conditionStartIndex = formatter.indexOfNextToken(fromIndex: i, matching: { $0.type != .whitespace }),
                let scopeStartIndex = formatter.indexOfNextToken(fromIndex: conditionStartIndex, matching: { $0.string == "{" }),
                let conditionEndIndex = formatter.indexOfPreviousToken(fromIndex: scopeStartIndex, matching: { !$0.isWhitespaceOrCommentOrLinebreak }) {
                if formatter.tokenAtIndex(conditionStartIndex)?.string != "(" || formatter.tokenAtIndex(conditionEndIndex)?.string != ")" {
                    formatter.insertToken(Token(.endOfScope, ")"), atIndex: conditionEndIndex + 1)
                    formatter.insertToken(Token(.startOfScope, "("), atIndex: conditionStartIndex)
                }
            }
        }
        
    }
    
    func transformSwitch(_ formatter: Formatter) {
        // Replace "switch" by
        // Find "case" inside {}
        // Find "default" inside {}
    }
    
    func transformIfLetStatement(_ formatter: Formatter) {
        //TODO:
    }
}
