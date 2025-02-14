//
//  ShareViewController.swift
//  Share url extension
//
//  Created by Laurent Jacques on 08/02/2025.
//

import UIKit
import Social
import os
import share_api

class ShareViewController: SLComposeServiceViewController {
    let logger = Logger(subsystem: "lj-conseil.share-url", category: "ShareExtension")
    
    let networkManager = NetworkManager()

    override func isContentValid() -> Bool {
        // Do validation of contentText and/or NSExtensionContext attachments here
        return true
    }
    
    fileprivate func sendData(_ url: URL) {
        Task {
            do {
                try await networkManager.sendData(url: url.absoluteString)
            } catch {
                self.logger.info("❌ Error sending data: \(error.localizedDescription)")
            }
            
        }
    }
    
    override func didSelectPost() {
        logger.info("✅ didSelectPost called!") // Debugging log

        if let inputItems = self.extensionContext?.inputItems as? [NSExtensionItem] {
            for item in inputItems {
                if let attachments = item.attachments {
                    for provider in attachments {
                        if provider.hasItemConformingToTypeIdentifier("public.url") {
                            provider.loadItem(forTypeIdentifier: "public.url", options: nil) { (urlItem, error) in
                                if let error = error {
                                    self.logger.info("❌ Error loading URL: \(error.localizedDescription)")
                                    return
                                }

                                if let url = urlItem as? URL {
                                    self.logger.info("✅ Extracted URL: \(url.absoluteString)")
                                    //self.saveToUserDefaults(url.absoluteString)
                                    self.sendData(url)
                                }
                            }
                            
                            // Close the extension
                            self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
                            return // Stop after finding the first valid URL
                        }
                    }
                }
            }
        }

        // Close the extension
        self.extensionContext?.completeRequest(returningItems: nil, completionHandler: nil)
    }

    func saveToUserDefaults(_ url: String) {
        let sharedDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier)
        sharedDefaults?.set(url, forKey: Constants.userDefaultShareKey)
        sharedDefaults?.synchronize()
        
        if let test: String = sharedDefaults?.string(forKey: Constants.appGroupIdentifier) {
            logger.info(" \(test)")
        }
        
        logger.info("✅ Saved URL: \(url)")
    }
}
