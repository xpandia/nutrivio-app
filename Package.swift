// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "Nutrivio",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "Nutrivio", targets: ["Nutrivio"])
    ],
    targets: [
        .target(name: "Nutrivio", path: "App")
    ]
)
