//
//  Constants.swift
//  share-url
//
//  Created by Laurent Jacques on 10/02/2025.
//

public class Constants {
    public static let appGroupIdentifier = "group.com.laurentjacquesshareurl.shared"
    public static let bundleIdentifier = "com.laurentjacques.shareurl"
    public static let userDefaultShare = "group.shareurl.shared"
    public static let urlShare = "shareurl://share-url"
    public static let userDefaultShareKey = "sharedURL"
    // The NAS IP: "ds224" alone doesn't resolve on iOS, and "ds224.local" costs ~5 s per lookup.
    public static let defaultServerURL = "http://10.0.4.83:3000"
    public static let serverUrlKey = "serverUrl"
    public static let apiTokenKey = "apiToken"
    public static let downloadPath = "/download"
    public static let statusPath = "/status"
    public static let clearHistoryPath = "/clear-history"
    public static let resolutionPath = "/resolutions"
    public static let healthPath = "/health"
}
