// swift-tools-version: 5.9
import PackageDescription

let package = Package(
    name: "HolyReminder",
    platforms: [
        .macOS(.v13)
    ],
    products: [
        .executable(name: "HolyReminder", targets: ["HolyReminder"])
    ],
    targets: [
        .executableTarget(
            name: "HolyReminder"
            // Resources removed - verses are now embedded in Swift code
            // to avoid Bundle.module crash on re-access
        )
    ]
)
