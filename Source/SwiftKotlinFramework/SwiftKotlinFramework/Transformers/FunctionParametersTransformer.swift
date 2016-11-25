//
//  FunctionParametersTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

class FunctionParametersTransformer: Transformer {
    let declarationTokens = ["var", "let", "class", "struct", "enum", "Self", "init", "func"]
    
    func transform(formatter: Formatter) throws {
        transformNamedParameterCalls(formatter)
        removeNamedParametersDeclarations(formatter)
        transformFunctionReturns(formatter)
    }
    
    func transformNamedParameterCalls(_ formatter: Formatter) {
        formatter.forEachToken(.symbol(":")) { (i, token) in
            //Check previous tokens:
            //when -> var, let -> then variable declaration, must not change
            //when -> class, struct, enum, Self -> then type declaration, must not change
            //when -> init, func -> then method declaration, must not change
            
            var isMethodInvocation = true
            var index = i - 1
            while let prevToken = formatter.tokenAtIndex(index) {
                guard !declarationTokens.contains(prevToken.string) else {
                    isMethodInvocation = false
                    break
                }
                //If new scope, check is not a clousure by assuming closures start with ( or [ (to be reviewed)
                if prevToken == .startOfScope("{") {
                    let token = formatter.nextNonWhitespaceOrCommentOrLinebreakToken(fromIndex: index)
                    if token?.string == "(" || token?.string == "[" {
                        isMethodInvocation = false
                        break
                    }
                }
                //If finds a . assumes method invocacion, and -> assumes function body (to be reviewed)
                if  prevToken == .symbol(".") ||
                    prevToken == .symbol("->"){
                    break;
                }
                index -= 1
            }
            
            if isMethodInvocation {
                formatter.replaceTokenAtIndex(i, with: .symbol("="))
                formatter.insertToken(.whitespace(" "), atIndex: i)
            }
        }
    }
    
    func transformFunctionReturns(_ formatter: Formatter) {
        var index = -1
        while let funcIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0 == .keyword("func") }) {
            if let returnIndex = formatter.indexOfNextToken(fromIndex: funcIndex, matching: { $0 == .symbol("->") }) {
                //Replace -> by :
                formatter.replaceTokenAtIndex(returnIndex, with: .symbol(":"))
                
                //Insert whitespace after : if none
                formatter.insertSpacingTokenIfNoneAtIndex(returnIndex + 1)
                
                //Remove extra whitespace before :
                if let prevToken = formatter.indexOfPreviousToken(fromIndex: returnIndex, matching: { !$0.isWhitespaceOrLinebreak }) {
                    formatter.removeSpacingOrLinebreakTokensAtIndex(prevToken + 1)
                }
            }
            index = funcIndex + 1
        }
        
    }
    
    func removeNamedParametersDeclarations(_ formatter: Formatter) {
        
    }
    
    
}
