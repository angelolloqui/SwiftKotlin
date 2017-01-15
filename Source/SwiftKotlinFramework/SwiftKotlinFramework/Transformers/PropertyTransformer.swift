//
//  PropertyTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 03/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

class PropertyTransformer: Transformer {
    
    func transform(formatter: Formatter) throws {
        transformComputedProperties(formatter)
        transformPrivateSetters(formatter)
        transformLateInitProperties(formatter)
    }
    
    func transformComputedProperties(_ formatter: Formatter) {
        var previousIndex = 0
        while let index = findFirstPropertyBodyIndex(formatter, fromIndex: previousIndex) {
            //Find a get or set keyword
            let getIndex = formatter.index(of: .identifier("get"), after: index)
            let setIndex = formatter.index(of: .identifier("set"), after: index)
            
            //Convert the getter if a getter is defined or there is no setter
            if getIndex != nil || setIndex == nil {
                transformGetterProperty(formatter, index: getIndex ?? index)
            }
            
            //Convert the setter if defined
            if let setIndex = formatter.index(of: .identifier("set"), after: index) {
                transformSetterProperty(formatter, index: setIndex)
            }
            
            //Replace var by val if no setter
            if  setIndex == nil,
                let varIndex = formatter.index(before: index, where: { $0.string == "var" }) {
                formatter.replaceToken(at: varIndex, with: .keyword("val"))
            }
            
            //If there is a "get" or "set" then remove the {} from the property
            if  getIndex != nil || setIndex != nil,
                let closeIndex = formatter.index(of: .endOfScope("}"), after: index) {
                formatter.removeToken(at: closeIndex)
                formatter.removeToken(at: index)
            }
            
            previousIndex = index + 1
        }
    }
    
    func transformGetterProperty(_ formatter: Formatter, index: Int) {
        let isExplicitGet = formatter.token(at: index) == .identifier("get")
        var position = index
        var tokens:[Token] = [
            .startOfScope("("),
            .endOfScope(")"),
        ]
        
        //Add "get" keyword if no explicit getter
        if isExplicitGet {
            position += 1
        }
        else {
            tokens.insert(.keyword("get"), at: 0)
            tokens.append(.space(" "))
        }
        
        formatter.insertTokens(tokens, at: position)
       
        //Add extra space if none
        if !(formatter.token(at: index - 1)?.isSpace ?? false) {
            formatter.insertToken(.space(" "), at: index)
        }
    }
    
    func transformSetterProperty(_ formatter: Formatter, index: Int) {
        //Consume spaces
        var position = index + 1
        while formatter.token(at: position)?.isSpaceOrCommentOrLinebreak ?? false {
            position += 1
        }
        
        //Check if the setter has a variable name, otherwise create it with "newValue" as name (default for swift)
        if formatter.token(at: position) == .startOfScope("{") {
            formatter.insertTokens([
                .startOfScope("("),
                .identifier("newValue"),
                .endOfScope(")")
            ], at: index + 1)
        }
    }
    
    func findFirstPropertyBodyIndex(_ formatter: Formatter, fromIndex: Int) -> Int? {
        //Find properties with the type: "var <name>:<type> {"
        for i in fromIndex..<formatter.tokens.count {
            guard formatter.token(at: i) == .keyword("var") else { continue }
            var index = i + 1
            
            //Consume spaces
            while formatter.token(at: index)?.isSpaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Consume name
            index += 1
            
            //Consume possible spaces
            while formatter.token(at: index)?.isSpaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Check there is a : and consume
            guard formatter.token(at: index)?.string == ":" else { continue }
            index += 1
            
            //Consume possible spaces
            while formatter.token(at: index)?.isSpaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Now consume identifiers, maps, optionals, unwrapping and generics
            while   let token = formatter.token(at: index),
                    token.isIdentifier || token.string == "<" || token.string == ">" || token.string == "[" || token.string == "]" || token.string == "?" || token.string == "!" || token.string == "." {
                index += 1
            }
            
            //Consume possible spaces
            while formatter.token(at: index)?.isSpaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Check there is a { and add to list
            guard formatter.token(at: index)?.string == "{" else { continue }
            return index
        }
        return nil
    }
    
    func transformPrivateSetters(_ formatter: Formatter) {
        //Look for "(set)" form
        formatter.forEach(.identifier("set")) { (i, token) in
            guard formatter.token(at: i - 1) == .startOfScope("(") &&
                formatter.token(at: i + 1) == .endOfScope(")") else {
                    return
            }
            guard let accessorIndex = formatter.index(before: i - 1, where:  { !$0.isSpaceOrLinebreak}) else { return }
            guard let lineBreak = formatter.index(after: i + 1, where: { $0.isLinebreak}) else { return }
            guard let nextWordIndex = formatter.index(after: i + 1, where: { !$0.isSpaceOrLinebreak }) else { return }
            let indentation = formatter.indentForLine(at: accessorIndex)
            
            //Append the "private set" to the end
            formatter.insertTokens([
                .linebreak("\n"),
                .space("\(indentation)\t"),
                formatter.token(at: accessorIndex)!,
                .space(" "),
                .identifier("set")
            ], at: lineBreak)
            
            //Remove the old accessor
            formatter.removeTokens(inRange: Range(uncheckedBounds: (lower: accessorIndex, upper: nextWordIndex)))
        }
    }
    
    func transformLateInitProperties(_ formatter: Formatter) {
        var previousIndex = 0
        while let index = findFirstLateInitPropertyIndex(formatter, fromIndex: previousIndex) {
            if let unwrappedIndex = formatter.index(after: index, where: { $0.isSymbol("!") }) {
                formatter.removeToken(at: unwrappedIndex)
                formatter.insertTokens([
                    .keyword("lateinit"),
                    .space(" ")
                    ], at: index)
            }
            previousIndex = index + 2
        }
    }
    
    func findFirstLateInitPropertyIndex(_ formatter: Formatter, fromIndex: Int) -> Int? {
        //Look for "var <name>:<Type>!" form
        for i in fromIndex..<formatter.tokens.count {
            guard formatter.token(at: i) == .keyword("var") else { continue }
            
            var index = i + 1
            
            //Consume spaces
            while formatter.token(at: index)?.isSpaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Check there is a name and consume
            guard formatter.token(at: index)?.isIdentifier ?? false else { continue }
            index += 1
            
            //Consume possible spaces
            while formatter.token(at: index)?.isSpaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Check there is a : and consume
            guard formatter.token(at: index)?.string == ":" else { continue }
            index += 1
            
            //Consume possible spaces
            while formatter.token(at: index)?.isSpaceOrCommentOrLinebreak ?? false {
                index += 1
            }
            
            //Now consume identifiers, maps and generics
            while  let token = formatter.token(at: index),
                token.isIdentifier || token.string == "<" || token.string == ">" || token.string == "[" || token.string == "]" || token.string == "." {
                    index += 1
            }
            
            //If there is a ! then return it
            if formatter.token(at: index)?.isSymbol("!") ?? false {
                return i
            }
        }
        return nil
    }

}
