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
    
    func transform(formatter: Formatter, options: TransformOptions? = nil) throws {
        transformNamedParameterCalls(formatter)
        removeNamedParametersDeclarations(formatter)
        transformFunctionReturns(formatter)
    }
    
    func transformNamedParameterCalls(_ formatter: Formatter) {
        formatter.forEach(.delimiter(":")) { (i, token) in
            //Check previous tokens:
            //when -> var, let -> then variable declaration, must not change
            //when -> class, struct, enum, Self -> then type declaration, must not change
            //when -> init, func -> then method declaration, must not change
            
            var isMethodInvocation = true
            var index = i - 1
            while let prevToken = formatter.token(at: index) {
                guard !declarationTokens.contains(prevToken.string) else {
                    isMethodInvocation = false
                    break
                }
                //If new scope, check is not a clousure by assuming closures start with ( or [ (to be reviewed)
                if prevToken == .startOfScope("{") {
                    let token = formatter.nextToken(after: index, where: { !$0.isSpaceOrCommentOrLinebreak})
                    if token?.string == "(" || token?.string == "[" {
                        isMethodInvocation = false
                        break
                    }
                }
                //If finds a . assumes method invocacion, and -> assumes function body (to be reviewed)
                if  prevToken.isSymbol(".") ||
                    prevToken.isSymbol("->") {
                    break;
                }
                index -= 1
            }
            
            if isMethodInvocation {
                formatter.replaceToken(at: i, with: .symbol("=", .infix))
                formatter.insertToken(.space(" "), at: i)
            }
        }
    }
    
    func transformFunctionReturns(_ formatter: Formatter) {
        var index = 0
        while index < formatter.tokens.count {
            if formatter.token(at: index) == .keyword("func") {
                if let returnIndex = formatter.index(after: index, where: { $0.isSymbol("->") }) {
                    //Replace -> by :
                    formatter.replaceToken(at: returnIndex, with: .symbol(":", .infix))
                    
                    //Insert whitespace after : if none
                    formatter.insertSpacingTokenIfNone(at: returnIndex + 1)
                    
                    //Remove extra whitespace before :
                    if let prevToken = formatter.index(before: returnIndex, where: { !$0.isSpaceOrLinebreak }) {
                        formatter.removeSpacingOrLinebreakTokens(at: prevToken + 1)
                    }
                    index = returnIndex
                }
            }
            index = index + 1
        }
        
        // transform ->() to ->void
        formatter.forEach(.startOfScope("(")) { i, _ in
            if (formatter.last(.nonSpaceOrCommentOrLinebreak, before: i) == .symbol("->", .infix)
                || formatter.last(.nonSpaceOrCommentOrLinebreak, before: i) == .symbol(":", .infix)),
                let nextIndex = formatter.index(of: .nonSpaceOrLinebreak, after: i, if: {
                    $0 == .endOfScope(")") }), !formatter.isArgumentToken(at: nextIndex) {
                // Replace with Void
                formatter.replaceTokens(inRange: i ... nextIndex, with: [.identifier("void")])
            }
        }
    }
    

    
    func removeNamedParametersDeclarations(_ formatter: Formatter) {
        var index = 0
        while index < formatter.tokens.count {
            if formatter.token(at: index) == .keyword("func") {
                var parameterPairIndex = formatter.index(of: .startOfScope("("), after: index)
                while parameterPairIndex != nil {
                    //Find first 2 tokens
                    if  let firstTokenIndex = formatter.index(after: parameterPairIndex!, where: { !$0.isSpaceOrCommentOrLinebreak }),
                        let secondToken = formatter.nextToken(after: firstTokenIndex, where: { !$0.isSpaceOrCommentOrLinebreak }) {
                        
                        //If second token is an identifier then is because is a named parameter. Remove external name
                        if secondToken.isIdentifier {
                            formatter.removeToken(at: firstTokenIndex)
                            formatter.removeSpacingOrLinebreakTokens(at: firstTokenIndex)
                        }
                    }
                    parameterPairIndex = formatter.index(of: .delimiter(","), after: parameterPairIndex!)
                }
            }
            index = index + 1
        }

    }
    
    
}
