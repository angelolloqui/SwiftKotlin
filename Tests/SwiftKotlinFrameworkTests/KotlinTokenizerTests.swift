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

        let expected = try String(contentsOf: kotlinURL).trimmingCharacters(in: .whitespacesAndNewlines)
        let translated = kotlinTokenizer.translate(path: swiftURL).tokens?
            .joinedValues().trimmingCharacters(in: .whitespacesAndNewlines) ?? ""

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


