import Foundation
import Security

class MacOSSecurityService: AuthServiceProtocol {
    private let serviceName = "com.startupdashboard.auth"
    private let accountKey = "PrimaryAccount"
    private let legacyAccountName = "Noah"
    private let nameKey = "com.startupdashboard.username"

    func authenticate(password: String) -> Bool {
        // Try current key first
        if let stored = getStoredPassword(for: accountKey), stored == password {
            return true
        }
        // Fallback to legacy key for migration
        if let stored = getStoredPassword(for: legacyAccountName), stored == password {
            // Migrate to new key
            setPassword(newPassword: password)
            return true
        }
        return false
    }

    private func getStoredPassword(for account: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: account,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data {
            return String(data: data, encoding: .utf8)
        }
        return nil
    }

    func setPassword(newPassword: String) {
        guard let data = newPassword.data(using: .utf8) else { return }

        // Remove existing if any
        let deleteQuery: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountKey
        ]
        SecItemDelete(deleteQuery as CFDictionary)

        // Add new with accessibility constraint
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountKey,
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlock
        ]
        SecItemAdd(query as CFDictionary, nil)
    }

    func isPasswordSet() -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: false
        ]
        let status = SecItemCopyMatching(query as CFDictionary, nil)
        return status == errSecSuccess || status == errSecInteractionNotAllowed
    }

    func getUserName() -> String {
        return UserDefaults.standard.string(forKey: nameKey) ?? NSFullUserName()
    }

    func setUserName(_ name: String) {
        UserDefaults.standard.set(name, forKey: nameKey)
    }
}
