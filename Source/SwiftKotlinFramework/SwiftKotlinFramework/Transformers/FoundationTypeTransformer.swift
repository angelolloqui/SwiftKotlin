//
//  FoundationTypeTransformer.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 14/01/2017.
//  Copyright © 2017 Angel G. Olloqui. All rights reserved.
//

import Foundation

class FoundationTypeTransformer: Transformer {
    
    func transform(formatter: Formatter) throws {
        transformAnyObjects(formatter)
    }
    
    func transformAnyObjects(_ formatter: Formatter) {
        formatter.forEach(where: {$0 == .identifier("Any") || $0 == .identifier("AnyObject")}) { (i, token) in
            formatter.replaceToken(at: i, with: .identifier("Object"))
        }
    }
    
}
