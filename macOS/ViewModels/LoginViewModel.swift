import Foundation
import Combine
import AppKit

class LoginViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    private let securityPolicy: SecurityPolicyServiceProtocol
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isErrorVisible = false

    var onLoginSuccess: (() -> Void)?

    init(authService: AuthServiceProtocol, securityPolicy: SecurityPolicyServiceProtocol) {
        self.authService = authService
        self.securityPolicy = securityPolicy
    }

    func login() {
        if securityPolicy.isLockedOut {
            errorMessage = "Account locked. Please try again in 15 minutes."
            isErrorVisible = true
            return
        }

        if authService.authenticate(password: password) {
            securityPolicy.resetAttempts()
            onLoginSuccess?()
        } else {
            securityPolicy.recordFailedAttempt()
            errorMessage = "Incorrect Password"
            isErrorVisible = true
            // Trigger shake animation in View
        }
    }

    func exit() {
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil as Any?)
        }
    }
}
