// swift-tools-version:4.0


import PackageDescription

let package = Package(
  name: "SwiftKotlin",
  products: [
    .executable(
      name: "SwiftKotlinCommandLine",
      targets: [
        "SwiftKotlinCommandLine",
      ]
    ),
/* Mac OSX apps not supported. Do manually:
 https://stackoverflow.com/a/45138790/378433
    .executable(
        name: "SwiftKotlinApp",
        targets: [
            "SwiftKotlinApp",
        ]
    ),
 */
    .library(
      name: "SwiftKotlinFramework",
      targets: [
        "SwiftKotlinFramework",
      ]
    ),
  ],
  dependencies: [
    .package(
      url: "https://github.com/yanagiba/swift-transform",
      .revision("bcd99a671f5376ef7d3c7f8d45a0297a94678785")
    ),
  ],
  targets: [
    .target(
      name: "SwiftKotlinFramework",
      dependencies: [
        "swift-transform",
      ]
    ),
    /*
    .target(
        name: "SwiftKotlinApp",
        dependencies: [
            "SwiftKotlinFramework",
        ]
    ),
 */
    .target(
        name: "SwiftKotlinCommandLine",
        dependencies: [
            "SwiftKotlinFramework",
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
