import Foundation

protocol SettingsServiceProtocol {
    func setString(_ value: String, forKey key: String)
    func getString(forKey key: String, defaultValue: String) -> String
    func setBool(_ value: Bool, forKey key: String)
    func getBool(forKey key: String, defaultValue: Bool) -> Bool
}

class MacOSSettingsService: SettingsServiceProtocol {
    private let defaults = UserDefaults.standard

    func setString(_ value: String, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getString(forKey key: String, defaultValue: String) -> String {
        return defaults.string(forKey: key) ?? defaultValue
    }

    func setBool(_ value: Bool, forKey key: String) {
        defaults.set(value, forKey: key)
    }

    func getBool(forKey key: String, defaultValue: Bool) -> Bool {
        if defaults.object(forKey: key) == nil { return defaultValue }
        return defaults.bool(forKey: key)
    }
}
