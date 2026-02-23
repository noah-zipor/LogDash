import Foundation
import Combine

class DashboardViewModel: ObservableObject {
    private var mediaService: MediaServiceProtocol
    private var appService: AppServiceProtocol
    private var systemMonitor: SystemMonitorServiceProtocol

    @Published var currentTime = ""
    @Published var currentDate = ""
    @Published var nowPlaying: MediaInfo?
    @Published var apps: [AppEntry] = []
    @Published var systemStats = SystemStats(cpuUsage: 0, memoryUsage: 0)

    private var cancellables = Set<AnyCancellable>()

    init(mediaService: MediaServiceProtocol, appService: AppServiceProtocol, systemMonitor: SystemMonitorServiceProtocol) {
        self.mediaService = mediaService
        self.appService = appService
        self.systemMonitor = systemMonitor

        self.mediaService.onMediaChanged = { [weak self] info in
            self?.nowPlaying = info
        }

        self.nowPlaying = self.mediaService.getCurrentMedia()
        self.appService.getInstalledApps { [weak self] apps in
            self?.apps = apps
        }

        startClock()
        startSystemMonitoring()
    }

    private func startSystemMonitoring() {
        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                if let stats = self?.systemMonitor.getStats() {
                    self?.systemStats = stats
                }
            }
            .store(in: &cancellables)
    }

    private func startClock() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                self?.updateTime()
            }
            .store(in: &cancellables)
        updateTime()
    }

    private func updateTime() {
        let now = Date()
        let timeFormatter = DateFormatter()
        timeFormatter.dateFormat = "HH:mm:ss"
        currentTime = timeFormatter.string(from: now)

        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEEE, MMMM d, yyyy"
        currentDate = dateFormatter.string(from: now)
    }

    func launchApp(app: AppEntry) {
        appService.launchApp(app: app)
    }
}
