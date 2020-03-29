//
//  KotlinTokenizerTests.swift
//  SwiftKotlinFrameworkTests
//
//  Created by Angel Luis Garcia on 26/08/2017.
//

import XCTest
import SwiftKotlinFramework

class KotlinTokenizerTests: XCTestCase {
    let kotlinTokenizer = KotlinTokenizer(
        tokenTransformPlugins: [
            XCTTestToJUnitTokenTransformPlugin(),
            FoundationMethodsTransformPlugin()
        ]
    )

    func testAll() {
        let files = try! FileManager().contentsOfDirectory(atPath: self.testFilePath)
        let swiftFiles = files
            .filter { $0.contains(".swift") }
            .map { $0.replacingOccurrences(of: ".swift", with: "")}

        for file in swiftFiles {
            try! testSource(file: file)
        }
    }
}

extension KotlinTokenizerTests {
    
    private func testSource(path: String? = nil, file: String) throws {
        let path = path ?? self.testFilePath
        let swiftURL = URL(fileURLWithPath: "\(path)/\(file).swift")
        let kotlinURL = URL(fileURLWithPath: "\(path)/\(file).kt")

        let expected = try String(contentsOf: kotlinURL).removingLineTrailingSpacing()
        let translated = kotlinTokenizer.translate(path: swiftURL).tokens?
            .joinedValues().removingLineTrailingSpacing() ?? ""

        if translated != expected {
            let difference = prettyFirstDifferenceBetweenStrings(translated, expected)
            NSLog("❌ \(file)")
            XCTFail(difference)
        } else {
            NSLog("✅ \(file)")
        }
    }

    private var testFilePath: String {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .deletingLastPathComponent()
            .appendingPathComponent("Assets")
            .appendingPathComponent("Tests")
            .appendingPathComponent("KotlinTokenizer")
            .path
    }
}

private extension String {
    func removingLineTrailingSpacing() -> String {
        return components(separatedBy: "\n")
            .map { $0.trimmingLastIndentSpacing() }
            .joined(separator: "\n")
            .trimmingCharacters(in: .whitespacesAndNewlines)
    }

    func trimmingLastIndentSpacing() -> String {
        var view = self[...]
        while view.last?.isWhitespace == true {
            view = view.dropLast()
        }
        return String(view)
    }
}
