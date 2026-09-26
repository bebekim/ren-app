// swift-tools-version:5.9
import PackageDescription

// 02 §2.1: RenDomain may import Foundation only, so a stray `import SwiftUI` here fails
// the build rather than passing review. RenApplication arrives with phase 1's use cases.
let package = Package(
    name: "RenCore",
    platforms: [.iOS(.v17)],
    products: [
        .library(name: "RenDomain", targets: ["RenDomain"]),
    ],
    targets: [
        .target(name: "RenDomain"),
        .testTarget(name: "RenDomainTests", dependencies: ["RenDomain"]),
    ]
)
