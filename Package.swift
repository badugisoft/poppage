// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "PopPage",
    platforms: [
        .macOS(.v14)
    ],
    products: [
        .executable(name: "PopPage", targets: ["PopPage"])
    ],
    targets: [
        .executableTarget(
            name: "PopPage",
            path: "Sources/PopPage",
            swiftSettings: [
                .swiftLanguageMode(.v5)
            ]
        )
    ]
)
