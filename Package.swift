// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "NoctisDomain",
    platforms: [.macOS(.v14)],
    products: [.library(name: "NoctisDomain", targets: ["NoctisDomain"])],
    targets: [
        .target(name: "NoctisDomain", path: "GothicLounge/Core"),
        .testTarget(name: "NoctisDomainTests", dependencies: ["NoctisDomain"], path: "Tests")
    ]
)
