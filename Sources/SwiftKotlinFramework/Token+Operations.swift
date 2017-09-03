//
//  Token+Operations.swift
//  SwiftKotlinFramework
//
//  Created by Angel Luis Garcia on 03/09/2017.
//

import Transform


extension Array where Iterator.Element == Token {
    func replacing(_ condition: (Token) -> Bool, with tokens: [Token]) -> [Token] {
        var newTokens = [Token]()
        for token in self {
            if condition(token) {
                newTokens.append(contentsOf: tokens)
            } else {
                newTokens.append(token)
            }
        }
        return newTokens
    }
}
