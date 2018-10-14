// swift-tools-version:4.0


import PackageDescription

let package = Package(
  name: "SwiftKotlinFramework",
  products: [
    .library(
      name: "SwiftKotlinFramework",
      targets: [
        "SwiftKotlinFramework",
      ]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/angelolloqui/swift-transform",
      .revision("3fc221cc73d30034bf1d32a21a42ba1474f21abf")
    ),
  ],
  targets: [
    .target(
      name: "SwiftKotlinFramework",
      dependencies: [
        "swift-transform",
      ],
      exclude: [
        "SwiftKotlin.xcworkspace"
      ]
    ),    

    // MARK: Tests
    .testTarget(
      name: "SwiftKotlinFrameworkTests",
      dependencies: [
        "SwiftKotlinFramework",
      ]
    ),    
  ],
  swiftLanguageVersions: [4]
)
