//
//  TestExtensions.swift
//  SwiftKotlinFramework
//
//  Created by Angel Garcia on 01/11/16.
//  Copyright © 2016 Angel G. Olloqui. All rights reserved.
//

import Foundation

extension Transformer {
    func translate(content: String) throws -> String {
        let tokens =  tokenize(content)
        let formatter = Formatter(tokens)
        try self.transform(formatter: formatter)
        return formatter.tokens.reduce("", { $0 + $1.string })
    }
}
