//
//  Utilities.swift
//  SwiftKotlinFramework
//
//  Created by Tor Langballe 07/07/2018.
//

import AST
import Transform

func changedValueToken(_ t:Token, _ val:String) -> Token {
    if let origin = t.origin, let node = t.node {
        return origin.newToken(t.kind, val, node)
    }
    return t
}

func stringHasPrefix(_ str:String, prefix:String, rest: inout String) -> Bool {
    if str.hasPrefix(prefix) {
        rest = String(str.dropFirst(prefix.count))
        return true
    }
    return false
}

extension Collection where Iterator.Element == [Token] {
    public func joinedWithCloseToken(token: Token) -> [Token] {
        var out = [Token]()
        let all = self.filter { !$0.isEmpty }
        for (i, a) in all.enumerated() {
            out += a
            if i != all.endIndex - 1 {
                out.append(a.last!.node!.newToken(token.kind, token.value))
            }
        }
        return out
    }
}

// return Array(self.filter { !$0.isEmpty }.flatMap { $0 + token }.dropLast())
