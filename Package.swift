// swift-tools-version: 6.0
import PackageDescription

let package = Package(
    name: "DiabetesProBR",
    platforms: [.iOS(.v17), .macOS(.v14)],
    products: [
        .library(name: "DiabetesProBRCore", targets: ["DiabetesProBRCore"]),
        .executable(name: "DiabetesProBRApp", targets: ["DiabetesProBRApp"])
    ],
    targets: [
        .target(name: "DiabetesProBRCore", resources: [.process("Resources")]),
        .executableTarget(name: "DiabetesProBRApp", dependencies: ["DiabetesProBRCore"]),
        .testTarget(name: "DiabetesProBRCoreTests", dependencies: ["DiabetesProBRCore"])
    ]
)
