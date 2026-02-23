import Foundation
import Combine
import AppKit

class SetupViewModel: ObservableObject {
    private let authService: AuthServiceProtocol
    private let securityPolicy: SecurityPolicyServiceProtocol
    @Published var password = ""
    @Published var confirmPassword = ""
    @Published var errorMessage = ""
    @Published var isErrorVisible = false

    var onSetupSuccess: (() -> Void)?

    init(authService: AuthServiceProtocol, securityPolicy: SecurityPolicyServiceProtocol) {
        self.authService = authService
        self.securityPolicy = securityPolicy
    }

    func setup() {
        if password.isEmpty {
            errorMessage = "Password cannot be empty"
            isErrorVisible = true
            return
        }

        if password != confirmPassword {
            errorMessage = "Passwords do not match"
            isErrorVisible = true
            return
        }

        authService.setPassword(newPassword: password)
        onSetupSuccess?()
    }

    func exit() {
        NSApp.terminate(nil as Any?)
    }
}
