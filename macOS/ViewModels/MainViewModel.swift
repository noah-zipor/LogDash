import Foundation
import SwiftUI
import Combine

class MainViewModel: ObservableObject {
    enum Screen {
        case welcome(WelcomeViewModel)
        case setup(SetupViewModel)
        case login(LoginViewModel)
        case dashboard(DashboardViewModel)
    }

    @Published var currentScreen: Screen

    let authService: AuthServiceProtocol
    let mediaService: MediaServiceProtocol
    let appService: AppServiceProtocol
    let securityPolicy: SecurityPolicyServiceProtocol
    let systemMonitor: SystemMonitorServiceProtocol

    private var cachedApps: [AppEntry] = []

    init(authService: AuthServiceProtocol,
         mediaService: MediaServiceProtocol,
         appService: AppServiceProtocol,
         securityPolicy: SecurityPolicyServiceProtocol,
         systemMonitor: SystemMonitorServiceProtocol) {
        self.authService = authService
        self.mediaService = mediaService
        self.appService = appService
        self.securityPolicy = securityPolicy
        self.systemMonitor = systemMonitor

        // Start with welcome
        let welcomeVM = WelcomeViewModel()
        self.currentScreen = .welcome(welcomeVM)
        setupWelcomeNavigation(welcomeVM)

        // Pre-fetch apps in background to make dashboard instant
        preFetchApps()
    }

    private func preFetchApps() {
        appService.getInstalledApps { [weak self] apps in
            self?.cachedApps = apps
        }
    }

    private func setupWelcomeNavigation(_ vm: WelcomeViewModel) {
        vm.onNavigationRequested = { [weak self] in
            guard let self = self else { return }
            if self.authService.isPasswordSet() {
                self.navigateToLogin()
            } else {
                self.navigateToSetup()
            }
        }
    }

    func navigateToSetup() {
        let setupVM = SetupViewModel(authService: authService, securityPolicy: securityPolicy)
        setupVM.onSetupSuccess = { [weak self] in
            self?.navigateToDashboard()
        }
        currentScreen = .setup(setupVM)
    }

    func navigateToLogin() {
        let loginVM = LoginViewModel(authService: authService, securityPolicy: securityPolicy)
        loginVM.onLoginSuccess = { [weak self] in
            self?.navigateToDashboard()
        }
        currentScreen = .login(loginVM)
    }

    func navigateToDashboard() {
        let dashboardVM = DashboardViewModel(mediaService: mediaService, appService: appService, systemMonitor: systemMonitor)
        if !cachedApps.isEmpty {
            dashboardVM.apps = cachedApps
        }
        currentScreen = .dashboard(dashboardVM)
    }
}
