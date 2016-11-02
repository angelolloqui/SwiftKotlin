//
//  NamedParametersTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 20/10/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

class NameParametersTransformer: Transformer {
    let declarationTokens = ["var", "let", "class", "struct", "enum", "Self", "init", "func"]
    
    func transform(formatter: Formatter) throws {
        
        formatter.forEachToken(":", ofType: .symbol) { (i, token) in
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
                if (prevToken.type == .symbol && prevToken.string == ".") ||
                    (prevToken.type == .symbol && prevToken.string == "->"){
                    break;
                }
                index -= 1
            }
            
            if isMethodInvocation {
                formatter.replaceTokenAtIndex(i, with: Token(token.type, " ="))
            }
        }
    }
    
}
