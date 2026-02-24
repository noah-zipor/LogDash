// swift-tools-version: 5.7
import PackageDescription

let package = Package(
    name: "StartupDashboard",
    platforms: [.macOS(.v12)],
    products: [
        .executable(name: "StartupDashboard", targets: ["StartupDashboard"]),
    ],
    dependencies: [],
    targets: [
        .executableTarget(
            name: "StartupDashboard",
            dependencies: [],
            path: "macOS",
            exclude: [
                "StartupDashboard/com.startupdashboard.launcher.plist",
                "Info.plist",
                "UI/Logo",
                "StartupDashboardTests"
            ]
        ),
        .testTarget(
            name: "StartupDashboardTests",
            dependencies: ["StartupDashboard"],
            path: "macOS/StartupDashboardTests"
        ),
    ]
)
