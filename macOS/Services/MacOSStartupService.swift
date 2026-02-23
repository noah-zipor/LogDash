import Foundation

class MacOSStartupService: StartupServiceProtocol {
    private let agentFileName = "com.startupdashboard.launcher.plist"

    private var agentPath: URL {
        let libraryDir = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask).first!
        return libraryDir.appendingPathComponent("LaunchAgents").appendingPathComponent(agentFileName)
    }

    func isRegisteredForStartup() -> Bool {
        return FileManager.default.fileExists(atPath: agentPath.path)
    }

    func registerForStartup() {
        _ = Bundle.main.bundlePath
        let executablePath = Bundle.main.executablePath ?? ""

        let plist: [String: Any] = [
            "Label": "com.startupdashboard.launcher",
            "ProgramArguments": [executablePath],
            "RunAtLoad": true,
            "KeepAlive": false
        ]

        let data = try? PropertyListSerialization.data(fromPropertyList: plist, format: .xml, options: 0)
        try? data?.write(to: agentPath)
    }

    func unregisterFromStartup() {
        try? FileManager.default.removeItem(at: agentPath)
    }
}
