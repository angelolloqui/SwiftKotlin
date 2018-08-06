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

