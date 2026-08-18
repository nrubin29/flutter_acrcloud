// swift-tools-version: 5.9

import PackageDescription

let package = Package(
  name: "flutter_acrcloud",
  platforms: [
    .iOS("15.0")
  ],
  products: [
    .library(name: "flutter-acrcloud", targets: ["flutter_acrcloud"])
  ],
  dependencies: [
    .package(name: "FlutterFramework", path: "../FlutterFramework")
  ],
  targets: [
    // ACRCloud iOS SDK v1.7.0.2, vendored as a dynamic binary framework.
    // Slices: ios-arm64, ios-arm64_x86_64-simulator, ios-arm64_x86_64-maccatalyst.
    .binaryTarget(
      name: "ACRCloudiOSSDK",
      path: "Frameworks/ACRCloudiOSSDK.xcframework"
    ),
    .target(
      name: "flutter_acrcloud",
      dependencies: [
        .product(name: "FlutterFramework", package: "FlutterFramework"),
        "ACRCloudiOSSDK",
      ],
      resources: [
        .process("PrivacyInfo.xcprivacy")
      ],
      linkerSettings: [
        .linkedFramework("AVFoundation"),
        .linkedFramework("AudioToolbox"),
        .linkedFramework("Security"),
        .linkedLibrary("c++"),
      ]
    )
  ]
)
