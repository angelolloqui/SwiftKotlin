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
        "switch"
    ]
    
    func transform(formatter: Formatter) throws {
        transformGuards(formatter)
        formatter.forEachToken { (i, token) in
            guard case .keyword(let string) = token, conditionals.contains(string) else { return }
            transformConditionStatement(formatter, index: i)
            if string == "switch" {
                transformSwitch(formatter, index: i)
            }
        }
    }
    
    func transformConditionStatement(_ formatter: Formatter, index: Int) {
        
        if  let conditionStartIndex = formatter.indexOfNextToken(fromIndex: index, matching: { !$0.isWhitespace }),
            let scopeStartIndex = formatter.indexOfNextToken(fromIndex: conditionStartIndex, matching: { $0.string == "{" }),
            var conditionEndIndex = formatter.indexOfPreviousToken(fromIndex: scopeStartIndex, matching: { !$0.isWhitespaceOrCommentOrLinebreak }) {
            if formatter.tokenAtIndex(conditionStartIndex)?.string != "(" || formatter.tokenAtIndex(conditionEndIndex)?.string != ")" {
                formatter.insertToken(.endOfScope(")"), atIndex: conditionEndIndex + 1)
                formatter.insertToken(.startOfScope("("), atIndex: conditionStartIndex)
                conditionEndIndex += 2
            }
            transformConditionalLetStatement(formatter, startIndex: conditionStartIndex, endIndex: conditionEndIndex)
        }
    }
    
    func transformConditionalLetStatement(_ formatter: Formatter, startIndex: Int, endIndex: Int) {
        //TODO: Split condition in multiple statementes separated by , if needed
        
        if  let firstTokenIndex = formatter.indexOfNextToken(fromIndex: startIndex, matching: { !$0.isWhitespaceOrCommentOrLinebreak }),
            let firstToken = formatter.tokenAtIndex(firstTokenIndex),
            firstToken.string == "let" || firstToken.string == "var" {
            if  let unwrappedVariableName = formatter.nextNonWhitespaceOrCommentOrLinebreakToken(fromIndex: firstTokenIndex),
                let assignementIndex = formatter.indexOfNextToken(fromIndex: firstTokenIndex, matching: { $0 == .symbol("=") }),
                let expressionIndex = formatter.indexOfNextToken(fromIndex: assignementIndex, matching: { !$0.isWhitespace }){
                let optionalExpressionTokens = formatter.tokens[expressionIndex..<endIndex]
                
                //When only unwrapping same variable name, in kotlin can be replaced by null check
                if optionalExpressionTokens.count == 1 && optionalExpressionTokens.first == unwrappedVariableName {
                    //Replace = and variable name by null check
                    formatter.replaceTokenAtIndex(assignementIndex, with: .symbol("!="))
                    formatter.replaceTokenAtIndex(endIndex - 1, with: .identifier("null"))
                    //Remove let and extra spacing
                    formatter.removeTokenAtIndex(firstTokenIndex)
                    formatter.removeSpacingTokensAtIndex(firstTokenIndex)
                }
                //This case needs an extra variable definition out of the "if"
                else {
                    //Move conditional expresion out of the "if"
                    let expressionTokens = formatter.tokens[firstTokenIndex..<endIndex]
                    formatter.removeTokensInRange(Range(uncheckedBounds: (lower: firstTokenIndex, upper: endIndex)))
                    let declarationIndex = formatter.indexOfPreviousToken(fromIndex: startIndex - 1, matching: { !$0.isWhitespace })!
                    formatter.insertToken(.linebreak("\n"), atIndex: declarationIndex)
                    formatter.insertTokens(Array(expressionTokens), atIndex: declarationIndex)
                    
                    //Add null check
                    let conditionTokenIndex = firstTokenIndex + expressionTokens.count
                    formatter.insertToken(unwrappedVariableName, atIndex: conditionTokenIndex + 1)
                    formatter.insertToken(.whitespace(" "), atIndex: conditionTokenIndex + 2)
                    formatter.insertToken(.symbol("!="), atIndex: conditionTokenIndex + 3)
                    formatter.insertToken(.whitespace(" "), atIndex: conditionTokenIndex + 4)
                    formatter.insertToken(.identifier("null"), atIndex: conditionTokenIndex + 5)
                }
            }
        }
    }
    
    func transformSwitch(_ formatter: Formatter, index: Int) {
        guard let bodyStartIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0 == .startOfScope("{") }) else { return }

        //Switch cases are special because they are not properly scoped. Fix it by just iterating on keywords to find all cases and body end
        var caseIndexes = [Int]()
        var colonIndexes = [Int]()
        var defaultIndex: Int?
        var scopeCount = 1
        var tokenIndex = bodyStartIndex
        var identifiersCount = 0
        repeat {
            tokenIndex += 1
            guard let token = formatter.tokenAtIndex(tokenIndex) else { break }
            
            if token == .endOfScope("}") {
                scopeCount -= 1
            }
            else if token == .startOfScope("{") {
                scopeCount += 1
            }
            else if token == .startOfScope(":") {
                //Check if it is a single identifier, in which case remove "in" and space
                if identifiersCount == 1 {
                    let index = caseIndexes.removeLast()
                    formatter.removeTokenAtIndex(index)
                    formatter.removeTokenAtIndex(index)                    
                    tokenIndex -= 2
                }
                colonIndexes.append(tokenIndex)
            }
            else if token.string == "case" {
                caseIndexes.append(tokenIndex)
                identifiersCount = 0
            }
            else if token.string == "default" {
                defaultIndex = tokenIndex
                identifiersCount = 0
            }
            else if !token.isWhitespaceOrCommentOrLinebreak {
                identifiersCount += 1
            }
        } while  scopeCount > 0
//        let bodyEndIndex = tokenIndex
        

        // Replace "switch" by "when"
        formatter.replaceTokenAtIndex(index, with: .keyword("when"))
        
        // Replace "case" inside {} by "in"
        caseIndexes.forEach {
            formatter.replaceTokenAtIndex($0, with: .endOfScope("in"))
        }

        // Replace "default" inside {} by "else"
        if let defaultIndex = defaultIndex {
            formatter.replaceTokenAtIndex(defaultIndex, with:  .endOfScope("else"))
        }
        
        // Replace ":" inside {} by "->" and add 1 space
        colonIndexes.reversed().forEach {
            formatter.replaceTokenAtIndex($0, with: .startOfScope("->"))
            formatter.insertToken(.whitespace(" "), atIndex: $0)
        }

    }
    
    func transformGuards(_ formatter: Formatter) {
        formatter.forEachToken(.keyword("guard")) { (i, token) in
            formatter.replaceTokenAtIndex(i, with: .keyword("if"))
            if let elseIndex = formatter.indexOfNextToken(fromIndex: i, matching: { $0.string == "else" }) {
                formatter.removeTokenAtIndex(elseIndex)
                formatter.removeSpacingTokensAtIndex(elseIndex)
            }
            transformConditionStatement(formatter, index: i)
            negateCondition(formatter, index: i)
        }
    }
    
    func negateCondition(_ formatter: Formatter, index: Int) {
        guard let scopeStartIndex = formatter.indexOfNextToken(fromIndex: index, matching: { $0.isStartOfScope }) else { return }
        let negationMap = ["==": "!=", "!=": "==", ">": "<=", "<": ">=", ">=": "<", "<=": ">"]
        if  let conditionIndex = formatter.indexOfNextToken(fromIndex: scopeStartIndex, matching: { negationMap.keys.contains($0.string) }),
            let condition = formatter.tokenAtIndex(conditionIndex)?.string,
            let negation = negationMap[condition] {
            formatter.replaceTokenAtIndex(conditionIndex, with: .symbol(negation))
        }
        else {
            //Negate the whole condition by using ! (or remove the !)
            if  let firstTokenIndex = formatter.indexOfNextToken(fromIndex: scopeStartIndex, matching: { !$0.isWhitespace }),
                let firstToken = formatter.tokenAtIndex(firstTokenIndex),
                firstToken.string == "!" {
                formatter.removeTokenAtIndex(firstTokenIndex)
            }
            else {
                formatter.insertToken(.symbol("!"), atIndex: scopeStartIndex + 1)
            }
        }        
    }
    
    
}
