import SwiftUI

@main
struct StartupDashboardApp: App {
    @StateObject var mainViewModel: MainViewModel

    init() {
        let auth = MacOSSecurityService()
        let media = MacOSMediaService()
        let app = AppServiceLauncher()
        let securityPolicy = SecurityPolicyService()
        let systemMonitor = MacOSSystemMonitorService()
        _mainViewModel = StateObject(wrappedValue: MainViewModel(
            authService: auth,
            mediaService: media,
            appService: app,
            securityPolicy: securityPolicy,
            systemMonitor: systemMonitor
        ))
    }

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(mainViewModel)
                .frame(minWidth: 1024, minHeight: 768)
                .onAppear {
                    DispatchQueue.main.async {
                        if let window = NSApplication.shared.windows.first {
                            window.toggleFullScreen(nil)
                        }
                    }
                }
        }
        .windowStyle(.hiddenTitleBar)
    }
}

struct ContentView: View {
    @EnvironmentObject var viewModel: MainViewModel

    var body: some View {
        Group {
            switch viewModel.currentScreen {
            case .welcome(let welcomeVM):
                WelcomeView(viewModel: welcomeVM)
            case .setup(let setupVM):
                SetupView(viewModel: setupVM)
            case .login(let loginVM):
                LoginView(viewModel: loginVM)
            case .dashboard(let dashboardVM):
                DashboardView(viewModel: dashboardVM)
            }
        }
        .transition(.opacity)
        .animation(.easeInOut, value: String(describing: viewModel.currentScreen))
    }
}

// Helper to make Screen equatable for animation
extension MainViewModel.Screen {
    var id: String {
        switch self {
        case .welcome: return "welcome"
        case .setup: return "setup"
        case .login: return "login"
        case .dashboard: return "dashboard"
        }
    }
}
