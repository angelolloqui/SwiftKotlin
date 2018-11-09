
//
//  IdentifiersTransformPlugin.swift
//
//  Created by Tor Langballe on 05/07/2018.
//
//

import Foundation
import Transform
import AST
import Source

private func findToken(kind:Token.Kind, val:String, tokens:[Token]) -> Int? {
    for (i, t) in tokens.enumerated() {
        if t.kind == kind && t.value == val {
            return i
        }
    }
    return nil
}

public class IdentifiersTransformPlugin: TokenTransformPlugin {
    public var name: String {
        return "Change identifiers"
    }
    
    public var description: String {
        return "Changes more functions and casts etc"
    }
    
    public init() {}
    
    // this does brute-force conversion of tokens at a general level. Maybe they can be done more in context, but I think it was hard or needed work in AST

    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        var newTokens = [Token]()
        
        for token in tokens {
            if let origin = token.origin, let node = token.node {
                switch token.value {
                case "&":
                    if token.kind == .identifier || token.kind == .symbol {
                        newTokens.append(origin.newToken(.keyword, "and", node))
                        continue
                    }

                case "|":
                    if token.kind == .identifier || token.kind == .symbol {
                        newTokens.append(origin.newToken(.keyword, "or", node))
                        continue
                    }

                case "enumerated":
                    if token.kind == .identifier {
                        newTokens.append(origin.newToken(.identifier, "withIndex", node))
                        continue
                    }
                
//                case "append":
//                    if token.kind == .identifier {
//                        if let p = newTokens.last, p.value == "." && p.kind == .delimiter {
//                            newTokens.removeLast()
//                            newTokens.append(origin.newToken(.identifier, " += ", node))
//                        }
//                        continue
//                    }
                    
                default:
                    break
                }
            }
            newTokens.append(token)
        }
        return newTokens
    }
    
    class func TransformKotlinFunctionDeclarations(_ tokens:[Token]) -> [Token] {
        // https://kotlinlang.org/docs/reference/operator-overloading.html
        var newTokens = tokens.filter { $0.kind != .keyword || $0.value != "mutating" }
        if let i = findToken(kind:.keyword, val:"fun", tokens:newTokens) {
            let j = i + 2
            let t = newTokens[j]
            if t.kind == .identifier {
                var name = ""
                // this allowes special operator_ prefixed functions to become operators in kotlin
                if stringHasPrefix(t.value, prefix:"operator_", rest:&name) {
                    newTokens[j] = changedValueToken(t, name)
                    if let origin = t.origin, let node = t.node {
                        newTokens.insert(origin.newToken(.space, " ", node), at:i)
                        let op = origin.newToken(.keyword, "operator", node)
                        newTokens.insert(op, at:i)

                    }
                }
            }
        }
        return newTokens
    }
    
    class func TransformKotlinFunctionCallExpression(_ tokens:[Token]) -> [Token] {
        if tokens.count >= 5 {
            if tokens[0].kind == .identifier && firstCharIsUpper(str:tokens[0].value) &&
                tokens[1].kind == .startOfScope && tokens[1].value == "(" &&
                tokens[2].kind == .identifier && tokens[2].value == "rawValue" {
                // this is a real hack that converts <Enum>(rawValue:xxx) to <Enum>.rawValue(xxx),
                var newTokens = [Token]()
                if let origin = tokens[0].origin, let node = tokens[0].node {
                    newTokens.append(tokens[0])
                    newTokens.append(origin.newToken(.symbol, ".", node))
                    newTokens.append(tokens[2])
                    newTokens.append(tokens[1])
                    newTokens += tokens[4...]
                }
                return newTokens
            }
        }
        if let f = tokens.first {
            if f.kind == .identifier {
                if let n = typeConversions[f.value] {
                    // converts Float(x) to x.toFloat() etc
                    return addRestExpressionCallingToName("to" + n, t:f, tokens:tokens)
                }
                // these convert max() to maxOf() etc
                if let origin = f.origin, let node = f.node {
                    switch f.value {
                    case "max":
                        return [origin.newToken(.identifier, "maxOf", node)] + tokens[1...]

                    case "min":
                        return [origin.newToken(.identifier, "minOf", node)] + tokens[1...]
                    default:
                        break
                    }
                }
            }
        }
        return tokens.map {
            if $0.kind == .identifier {
                return IdentifiersTransformPlugin.TransformType($0)
            }
            return $0
        }
    }
    
    class func TransformType(_ t:Token) -> Token {
        // this converts Bool to Boolean etc and all 
        if let name = typeConversions[t.value] {
            return changedValueToken(t, name)
        }
        return t
    }
}

private func addRestExpressionCallingToName(_ name:String, t:Token, tokens:[Token]) -> [Token] {
    if let origin = t.origin, let node = t.node {
        var exp = [Token](tokens[1...])
        if exp.count == 3 {
            exp = [exp[1]]
        }
        if exp.count == 1 && name == "toFloat" {
            let s = exp[0].value
            if let _ = Int(s) {
                return [origin.newToken(.number, s + "f", node)]
            }
        }
        return
            exp +
            origin.newToken(.symbol, ".", node) +
            origin.newToken(.identifier, name, node) +
            origin.newToken(.startOfScope, "(", node) +
            origin.newToken(.endOfScope, ")", node)
    }
    return tokens
}

//private func firstCharIsUpper(str:String) -> Bool {
//    let s = String(str.first!)
//    return s == s.uppercased()
//}
//
//
