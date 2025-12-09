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
            name: "HolyReminder",
            resources: [
                .process("Resources")
            ]
        )
    ]
)
