import Foundation

protocol SecurityPolicyServiceProtocol {
    var isLockedOut: Bool { get }
    func recordFailedAttempt()
    func resetAttempts()
}

class SecurityPolicyService: SecurityPolicyServiceProtocol {
    private var failedAttempts = 0
    private let maxAttempts = 5
    private var lockoutExpiry = Date.distantPast

    var isLockedOut: Bool {
        return Date() < lockoutExpiry
    }

    func recordFailedAttempt() {
        failedAttempts += 1
        if failedAttempts >= maxAttempts {
            lockoutExpiry = Date().addingTimeInterval(900) // 15 minutes
        }
    }

    func resetAttempts() {
        failedAttempts = 0
        lockoutExpiry = Date.distantPast
    }
}
