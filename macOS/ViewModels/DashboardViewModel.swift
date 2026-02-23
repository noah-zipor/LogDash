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
    @Published var searchQuery = ""

    // Cached formatters — allocating DateFormatter is expensive; cache for performance
    private let timeFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "HH:mm:ss"
        return f
    }()

    private let dateFormatter: DateFormatter = {
        let f = DateFormatter()
        f.dateFormat = "EEEE, MMMM d, yyyy"
        return f
    }()

    private var cancellables = Set<AnyCancellable>()

    var filteredApps: [AppEntry] {
        if searchQuery.isEmpty { return apps }
        return apps.filter { $0.name.localizedCaseInsensitiveContains(searchQuery) }
    }

    init(mediaService: MediaServiceProtocol, appService: AppServiceProtocol, systemMonitor: SystemMonitorServiceProtocol) {
        self.mediaService = mediaService
        self.appService = appService
        self.systemMonitor = systemMonitor

        self.mediaService.onMediaChanged = { [weak self] info in
            DispatchQueue.main.async { self?.nowPlaying = info }
        }

        self.nowPlaying = self.mediaService.getCurrentMedia()
        self.appService.getInstalledApps { [weak self] apps in
            self?.apps = apps
        }

        startClock()
        startSystemMonitoring()
    }

    private func startSystemMonitoring() {
        // First sample after 0.5 s so the delta CPU reading is meaningful
        DispatchQueue.global(qos: .utility).asyncAfter(deadline: .now() + 0.5) { [weak self] in
            guard let self = self else { return }
            // Warm up delta
            _ = self.systemMonitor.getStats()
        }

        Timer.publish(every: 2.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in
                guard let self = self else { return }
                DispatchQueue.global(qos: .utility).async {
                    let stats = self.systemMonitor.getStats()
                    DispatchQueue.main.async { self.systemStats = stats }
                }
            }
            .store(in: &cancellables)
    }

    private func startClock() {
        Timer.publish(every: 1.0, on: .main, in: .common)
            .autoconnect()
            .sink { [weak self] _ in self?.updateTime() }
            .store(in: &cancellables)
        updateTime()
    }

    private func updateTime() {
        let now = Date()
        currentTime = timeFormatter.string(from: now)
        currentDate = dateFormatter.string(from: now)
    }

    func launchApp(app: AppEntry) {
        appService.launchApp(app: app)
    }
}
