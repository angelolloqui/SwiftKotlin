// swift-tools-version:5.1


import PackageDescription

let package = Package(
    name: "SwiftKotlinFramework",
    products: [
        .library(
            name: "SwiftKotlinFramework",
            targets: ["SwiftKotlinFramework"]
        )],
    dependencies: [
        .package(url: "https://github.com/yanagiba/swift-transform", .exact("0.19.9"))
    ],
    targets: [

        // MARK: Main framework
        .target(
            name: "SwiftKotlinFramework",
            dependencies: ["swift-transform"],
            exclude: [
                "SwiftKotlin.xcworkspace"
            ]
        ),

        // MARK: Tests
        .testTarget(
            name: "SwiftKotlinFrameworkTests",
            dependencies: ["SwiftKotlinFramework"],
            exclude: [
                "SwiftKotlin.xcworkspace"
            ]
        )
    ]
)
