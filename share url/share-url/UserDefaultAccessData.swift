//
//  UserDefaultAccessData.swift
//  share-url
//
//  Created by Laurent Jacques on 21/02/2025.
//
import Foundation
import share_api

/// App Group defaults, so the share extension sees the same server URL.
class UserDefaultAccessData: AccessDataProtocol {
    private let defaults = UserDefaults(suiteName: Constants.appGroupIdentifier) ?? .standard

    init() {
        // Builds before Nov 2026 saved every value under the literal key "key" in standard defaults.
        if defaults.string(forKey: Constants.serverUrlKey) == nil,
           let legacy = UserDefaults.standard.string(forKey: "key"), !legacy.isEmpty {
            defaults.set(legacy, forKey: Constants.serverUrlKey)
            UserDefaults.standard.removeObject(forKey: "key")
        }
    }

    func save(key: String, value: String) {
        defaults.set(value, forKey: key)
    }

    func load(key: String) -> String? {
        if key == Constants.serverUrlKey { return ServerSettings.serverURL }  // trimmed, default applied
        return defaults.string(forKey: key)
    }
}
