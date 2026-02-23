import Foundation

protocol SecurityPolicyServiceProtocol {
    var isLockedOut: Bool { get }
    func recordFailedAttempt()
    func resetAttempts()
}

class SecurityPolicyService: SecurityPolicyServiceProtocol {
    private(set) var failedAttempts = 0
    private let maxAttempts = 5
    private(set) var lockoutExpiry = Date.distantPast

    var isLockedOut: Bool {
        return Date() < lockoutExpiry
    }

    var attemptsRemaining: Int {
        return max(0, maxAttempts - failedAttempts)
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
