//
//  PreferencesSingleton.swift
//  SingletonDesignPattern
//
//  Created by Lee Danatech on 2021/5/12.
//

import Foundation

class UserPreferences {
    enum Preferences {
        enum UserCredentials: String {
            case passwordVisible
            case password
            case username
        }

        enum AppState: String {
            case appFirstRun
            case dateLastRun
            case currentVersion
        }
    }

    // MARK: - Properties
    static let shared = UserPreferences()

    private let userPreferences: UserDefaults

    // MARK: - Init Functions
    private init() {
        userPreferences = UserDefaults.standard
    }

    // MARK: - Internal Functions
    func setBooleanForKey(_ boolean: Bool, key: String) {
        guard !key.isEmpty else {
            return
        }
        userPreferences.set(boolean, forKey: key)
    }

    func getBooleanForKey(_ key: String) -> Bool {
        guard let isBooleanValue = userPreferences.value(forKey: key) as? Bool else {
            return false
        }
        return isBooleanValue
    }

    func isPasswordVisible() -> Bool {
        return getBooleanForKey(Preferences.UserCredentials.passwordVisible.rawValue)
    }

    func setPasswordVisibity(_ boolean: Bool) {
        setBooleanForKey(boolean, key: Preferences.UserCredentials.passwordVisible.rawValue)
    }
}
