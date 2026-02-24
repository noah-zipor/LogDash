// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "LogDash",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "LogDashExecutable", targets: ["LogDashExecutable"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "LogDashExecutable",
            dependencies: [],
            path: "macOS",
            exclude: [
                "StartupDashboard/com.startupdashboard.launcher.plist",
                "Info.plist",
                "StartupDashboardTests"
            ],
            resources: [
                .process("UI/Logo")
            ]
        ),
        .testTarget(
            name: "StartupDashboardTests",
            dependencies: ["LogDashExecutable"],
            path: "macOS/StartupDashboardTests"
        ),
    ]
)
