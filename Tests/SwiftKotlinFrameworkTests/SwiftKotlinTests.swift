//
//  SwiftKotlinTests.swift
//  SwiftKotlinFrameworkTests
//
//  Created by Angel Luis Garcia on 26/08/2017.
//

import XCTest
import SwiftKotlinFramework

class SwiftKotlinTests: XCTestCase {
    let kotlinTokenizer = KotlinTokenizer()

    func testSpecificFile() {
        try! testSource(file: "string_interpolator")
    }

    func testAll() {
        let files = try! FileManager().contentsOfDirectory(atPath: self.testFilePath)
        let swiftFiles = files
            .filter { $0.contains(".swift") }
            .map { $0.replacingOccurrences(of: ".swift", with: "")}

        for file in swiftFiles {
            try! testSource(file: file)
        }
    }

    private func testSource(path: String? = nil, file: String) throws {
        let path = path ?? self.testFilePath
        let swiftURL = URL(fileURLWithPath: "\(path)/\(file).swift")
        let kotlinURL = URL(fileURLWithPath: "\(path)/\(file).kt")

        let expected = try String(contentsOf: kotlinURL).trimmingCharacters(in: .whitespacesAndNewlines)
        let translated = try kotlinTokenizer.translate(path: swiftURL).joinedValues().trimmingCharacters(in: .whitespacesAndNewlines)

        if translated != expected {
            let difference = prettyFirstDifferenceBetweenStrings(translated, expected)
            NSLog("❌ \(file)")
            XCTFail(difference)
        } else {
            NSLog("✅ \(file)")
        }
    }

    var testFilePath: String {
        return URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("Tests")
            .path
    }
}


