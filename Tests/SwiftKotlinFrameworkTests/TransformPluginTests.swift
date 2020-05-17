//
//  TransformPluginTests.swift
//  SwiftKotlinFrameworkTests
//
//  Created by Angel Luis Garcia on 14/10/2017.
//

import XCTest
@testable import SwiftKotlinFramework

class TransformPluginTests: XCTestCase {
    
    func testXCTestToJUnitPlugin() {        
        try! testTokenTransformPlugin(
            plugin: XCTTestToJUnitTokenTransformPlugin(),
            file: "XCTTestToJUnitTokenTransformPlugin")
    }

    func testFoundationTransformPlugin() {
        try! testTokenTransformPlugin(
            plugin: FoundationMethodsTransformPlugin(),
            file: "FoundationMethodsTransformPlugin")
    }

    func testCommentsAdditionTransformPlugin() {
        try! testTokenTransformPlugin(
            plugin: CommentsAdditionTransformPlugin(),
            file: "CommentsAdditionTransformPlugin")
    }

    func testUIKitTransformPlugin() {
        try! testTokenTransformPlugin(
            plugin: UIKitTransformPlugin(),
            file: "UIKitTransformPlugin")
    }

}

extension TransformPluginTests {
    
    private func testTokenTransformPlugin(plugin: TokenTransformPlugin, file: String) throws {
        let kotlinTokenizer = KotlinTokenizer()
        kotlinTokenizer.sourceTransformPlugins = []
        kotlinTokenizer.tokenTransformPlugins = [plugin]

        let path = self.testFilePath
        let swiftURL = URL(fileURLWithPath: "\(path)/\(file).swift")
        let kotlinURL = URL(fileURLWithPath: "\(path)/\(file).kt")

        let expected = try String(contentsOf: kotlinURL).trimmingCharacters(in: .whitespacesAndNewlines)
        let translated = kotlinTokenizer.translate(paths: [swiftURL]).first?.tokens?
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
            .appendingPathComponent("plugins")
            .path
    }
}
