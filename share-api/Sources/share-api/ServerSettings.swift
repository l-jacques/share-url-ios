//
//  ServerSettings.swift
//  share-api
//
import Foundation

/// Server URL shared by the app and the share extension (App Group defaults: the extension can't read the
/// app's standard defaults).
public enum ServerSettings {
    private static var defaults: UserDefaults {
        UserDefaults(suiteName: Constants.appGroupIdentifier) ?? .standard
    }

    /// Saved server URL without trailing slash, or the default.
    public static var serverURL: String {
        get {
            let saved = defaults.string(forKey: Constants.serverUrlKey)?
                .trimmingCharacters(in: .whitespacesAndNewlines) ?? ""
            let url = saved.isEmpty ? Constants.defaultServerURL : saved
            return url.hasSuffix("/") ? String(url.dropLast()) : url
        }
        set { defaults.set(newValue, forKey: Constants.serverUrlKey) }
    }

    public static func url(_ path: String) -> String { serverURL + path }
}
