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
        "switch",
        "guard"
    ]
    
    func transform(formatter: Formatter) throws {
        transformGuard(formatter)
        transformSwitch(formatter)
        transformGeneralConditionStatement(formatter)
    }
    
    func transformGeneralConditionStatement(_ formatter: Formatter) {
        
        formatter.forEachToken(ofType: .identifier) { (i, token) in
            guard conditionals.contains(token.string) else { return }
            if  let conditionStartIndex = formatter.indexOfNextToken(fromIndex: i, matching: { $0.type != .whitespace }),
                let scopeStartIndex = formatter.indexOfNextToken(fromIndex: conditionStartIndex, matching: { $0.string == "{" }),
                var conditionEndIndex = formatter.indexOfPreviousToken(fromIndex: scopeStartIndex, matching: { !$0.isWhitespaceOrCommentOrLinebreak }) {
                if formatter.tokenAtIndex(conditionStartIndex)?.string != "(" || formatter.tokenAtIndex(conditionEndIndex)?.string != ")" {
                    formatter.insertToken(Token(.endOfScope, ")"), atIndex: conditionEndIndex + 1)
                    formatter.insertToken(Token(.startOfScope, "("), atIndex: conditionStartIndex)
                    conditionEndIndex += 2
                }
                transformConditionalLetStatement(formatter, startIndex: conditionStartIndex + 1, endIndex: conditionEndIndex)
            }
        }
        
    }
    
    func transformConditionalLetStatement(_ formatter: Formatter, startIndex: Int, endIndex: Int) {
        if let token = formatter.tokenAtIndex(startIndex),
            token.string == "let" || token.string == "var" {
            if  let unwrappedVariableName = formatter.nextNonWhitespaceOrCommentOrLinebreakToken(fromIndex: startIndex),
                let assignementIndex = formatter.indexOfNextToken(fromIndex: startIndex + 1, matching: { $0.type == .symbol && $0.string == "=" }),
                let expressionIndex = formatter.indexOfNextToken(fromIndex: assignementIndex, matching: { $0.type != .whitespace }){
                let optionalExpressionTokens = formatter.tokens[expressionIndex..<endIndex]
                
                //When only unwrapping same variable name, in kotlin can be replaced by null check
                if optionalExpressionTokens.count == 1 && optionalExpressionTokens.first == unwrappedVariableName {
                    //Replace = and variable name by null check
                    formatter.replaceTokenAtIndex(assignementIndex, with: Token(.symbol, "!="))
                    formatter.replaceTokenAtIndex(endIndex - 1, with: Token(.identifier, "null"))
                    //Remove let and extra spacing
                    formatter.removeTokenAtIndex(startIndex)
                    while formatter.tokenAtIndex(startIndex)?.type == .whitespace {
                        formatter.removeTokenAtIndex(startIndex)
                    }
                }
                //This case needs an extra variable definition out of the "if"
                else {
                    
                }
            }
        }
    }
    
    func transformSwitch(_ formatter: Formatter) {
        // Replace "switch" by "when"
        // Replace "case" inside {} by "in" and ":" by "->"
        // Replace "default" inside {} by "else"
    }
    
    func transformGuard(_ formatter: Formatter) {
        formatter.forEachToken("guard", ofType: .identifier) { (i, token) in
            formatter.replaceTokenAtIndex(i, with: Token(.identifier, "if"))
            if let elseIndex = formatter.indexOfNextToken(fromIndex: i, matching: { $0.string == "else" }) {
                formatter.removeTokenAtIndex(elseIndex)
            }
            //TODO: Negate condition
        }
    }
    
}
