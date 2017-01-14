//
//  TokenizerExtensions.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 04/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation


extension Token {    
    
    public var isKeyword: Bool {
        if case .keyword = self {
            return true
        }
        return false
    }
    
    func with(string: String) -> Token {
        switch self {
        case .number(_, let type): return .number(string, type)
        case .linebreak(_): return .linebreak(string)
        case .startOfScope(_): return .startOfScope(string)
        case .endOfScope(_): return .endOfScope(string)
        case .delimiter(_): return .delimiter(string)
        case .symbol(_, let symbolType): return .symbol(string, symbolType)
        case .stringBody(_): return .stringBody(string)
        case .keyword(_): return .keyword(string)
        case .identifier(_): return .identifier(string)
        case .space(_): return .space(string)
        case .commentBody(_): return .commentBody(string)
        case .error(_): return .error(string)
        }
    }    

}
