//
//  AppDelegate.swift
//  share-url
//
//  Created by Laurent Jacques on 10/02/2025.
//

import UIKit

class AppDelegate: UIResponder, UIApplicationDelegate {
    func application(_ app: UIApplication, open url: URL, options: [UIApplication.OpenURLOptionsKey : Any] = [:]) -> Bool {
        print("App opened via deep link: \(url.absoluteString)")
        NotificationCenter.default.post(name: .deepLinkReceived, object: url)
        return true
    }
}
