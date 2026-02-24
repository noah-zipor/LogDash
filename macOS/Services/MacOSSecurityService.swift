import Foundation
import Security

class MacOSSecurityService: AuthServiceProtocol {
    private let serviceName = "com.startupdashboard.auth"
    private let accountKey = "PrimaryAccount" // Stable key for Keychain
    private let nameKey = "com.startupdashboard.username"

    func authenticate(password: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrService as String: serviceName,
            kSecAttrAccount as String: accountKey,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]

        var dataTypeRef: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

        if status == errSecSuccess, let data = dataTypeRef as? Data, let storedPassword = String(data: data, encoding: .utf8) {
            return storedPassword == password
        }

        return false
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
