//
//  Token+Operations.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 03/09/2017.
//

import Transform

extension Array where Iterator.Element == Token {
    func replacing(_ condition: (Token) -> Bool, with tokens: [Token], amount: Int = Int.max) -> [Token] {
        var count = 0
        var newTokens = [Token]()
        for token in self {
            if count < amount && condition(token) {
                newTokens.append(contentsOf: tokens)
                count+=1
            } else {
                newTokens.append(token)
            }
        }
        return newTokens
    }

}

