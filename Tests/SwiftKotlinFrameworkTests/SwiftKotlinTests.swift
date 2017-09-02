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

    func testAll() throws {
        let directoryPath = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("Tests").path

        let files = try FileManager().contentsOfDirectory(atPath: directoryPath)
        let swiftFiles = files
            .filter { $0.contains(".swift") }
            .map { $0.replacingOccurrences(of: ".swift", with: "")}

        for file in swiftFiles {
            let swiftURL = URL(fileURLWithPath: "\(directoryPath)/\(file).swift")
            let kotlinURL = URL(fileURLWithPath: "\(directoryPath)/\(file).kt")

            let expected = try String(contentsOf: kotlinURL).trimmingCharacters(in: .whitespacesAndNewlines)
            let translated = try kotlinTokenizer.translate(path: swiftURL).joinedValues().trimmingCharacters(in: .whitespacesAndNewlines)

            if translated != expected {
                let difference = prettyFirstDifferenceBetweenStrings(translated, expected)
                XCTFail("\nTest failed translating file: \(file) -> \(difference)")
            }
        }
    }

}


