import Foundation

protocol AuthServiceProtocol {
    func authenticate(password: String) -> Bool
    func setPassword(newPassword: String)
    func isPasswordSet() -> Bool
}

struct MediaInfo {
    let title: String
    let artist: String
    let albumArt: Data?
    let isPlaying: Bool
}

protocol MediaServiceProtocol {
    func getCurrentMedia() -> MediaInfo?
    var onMediaChanged: ((MediaInfo) -> Void)? { get set }
}

struct AppEntry: Identifiable {
    let id = UUID()
    let name: String
    let bundleIdentifier: String
    let icon: Data?
}

protocol AppServiceProtocol {
    func getInstalledApps(completion: @escaping ([AppEntry]) -> Void)
    func launchApp(app: AppEntry)
}

protocol StartupServiceProtocol {
    func isRegisteredForStartup() -> Bool
    func registerForStartup()
    func unregisterFromStartup()
}

struct SystemStats {
    let cpuUsage: Double
    let memoryUsage: Double
    let diskUsage: Double     // 0–100 %
    let batteryLevel: Double  // 0–100 % (or -1 if desktop/unavailable)
    let isCharging: Bool

    init(cpuUsage: Double, memoryUsage: Double, diskUsage: Double = -1, batteryLevel: Double = -1, isCharging: Bool = false) {
        self.cpuUsage = cpuUsage
        self.memoryUsage = memoryUsage
        self.diskUsage = diskUsage
        self.batteryLevel = batteryLevel
        self.isCharging = isCharging
    }
}

protocol SystemMonitorServiceProtocol {
    func getStats() -> SystemStats
}
