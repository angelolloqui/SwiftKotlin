
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
    
    public func transform(tokens: [Token], topDeclaration: TopLevelDeclaration) throws -> [Token] {
        var newTokens = [Token]()
        
        for token in tokens {
            if token.kind == .identifier, let origin = token.origin, let node = token.node {
                switch token.value {
                case "enumerated":
                    newTokens.append(origin.newToken(.identifier, "withIndex", node))
                    continue
                
                case "append":
                    if let p = newTokens.last, p.value == "." && p.kind == .delimiter {
                        newTokens.removeLast()
                        newTokens.append(origin.newToken(.identifier, " += ", node))
                    }
                    continue
                    
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
        if let f = tokens.first {
            if f.kind == .identifier {
                if let n = typeConversions[f.value] {
                    return addRestExpressionCallingToName("to" + n, t:f, tokens:tokens)
                }
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
        return
            exp +
            origin.newToken(.symbol, ".", node) +
            origin.newToken(.identifier, name, node) +
            origin.newToken(.startOfScope, "(", node) +
            origin.newToken(.endOfScope, ")", node)
    }
    return tokens
}


