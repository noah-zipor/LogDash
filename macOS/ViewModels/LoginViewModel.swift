import Foundation
import Combine
import AppKit

class LoginViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    private let securityPolicy: SecurityPolicyService
    @Published var password = ""
    @Published var errorMessage = ""
    @Published var isErrorVisible = false
    @Published var attemptsRemaining: Int

    var onLoginSuccess: (() -> Void)?

    init(authService: AuthServiceProtocol, securityPolicy: SecurityPolicyService) {
        self.authService = authService
        self.securityPolicy = securityPolicy
        self.attemptsRemaining = securityPolicy.attemptsRemaining
    }

    func login() {
        // Clear previous error immediately so shake triggers again if needed
        isErrorVisible = false

        if securityPolicy.isLockedOut {
            let remaining = Int(securityPolicy.lockoutExpiry.timeIntervalSinceNow / 60) + 1
            errorMessage = "Locked out. Try again in \(remaining) min."
            isErrorVisible = true
            return
        }

        if authService.authenticate(password: password) {
            securityPolicy.resetAttempts()
            // Zero-out password from memory immediately
            password = String(repeating: "\0", count: password.count)
            password = ""
            onLoginSuccess?()
        } else {
            securityPolicy.recordFailedAttempt()
            attemptsRemaining = securityPolicy.attemptsRemaining
            if securityPolicy.isLockedOut {
                errorMessage = "Too many attempts. Locked for 15 minutes."
            } else {
                let tries = securityPolicy.attemptsRemaining
                errorMessage = tries > 0
                    ? "Incorrect password. \(tries) attempt\(tries == 1 ? "" : "s") remaining."
                    : "Incorrect password."
            }
            isErrorVisible = true
        }
    }

    func exit() {
        DispatchQueue.main.async {
            NSApplication.shared.terminate(nil as Any?)
        }
    }
}
