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
}

protocol SystemMonitorServiceProtocol {
    func getStats() -> SystemStats
}
