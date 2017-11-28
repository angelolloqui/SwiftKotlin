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
      url: "https://github.com/angelolloqui/swift-transform",
      .revision("3fc221cc73d30034bf1d32a21a42ba1474f21abf")
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
