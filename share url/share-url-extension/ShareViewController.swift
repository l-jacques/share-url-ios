//
//  ShareViewController.swift
//  Share url extension
//
//  Created by Laurent Jacques on 08/02/2025.
//

import UIKit
import UniformTypeIdentifiers
import Social
import share_api
import SwiftUI

class ShareViewController: SLComposeServiceViewController {
    // Use SLComposeServiceViewController as the base class for better share sheet integration
    
    // The URL to be shared
    private var sharedURL: String?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        title = "Share It"
        
        // Set placeholder text
        self.placeholder = "URL will be shared to your server"
        
        // Handle the shared items
        extractSharedText()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        // Show the custom UI if a URL was extracted
        if let urlString = sharedURL {
            presentCustomInterface(with: urlString)
        }
    }
    
    private func extractSharedText() {
        // Get the extension item
        guard let extensionItem = extensionContext?.inputItems.first as? NSExtensionItem,
              let itemProvider = extensionItem.attachments?.first else {
            return
        }
        
        // Try to get URL first
        if itemProvider.hasItemConformingToTypeIdentifier(UTType.url.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.url.identifier, options: nil) { [weak self] (item, error) in
                guard let self = self else { return }
                if let url = item as? URL {
                    self.processExtractedText(url.absoluteString)
                }
            }
        }
        // Fall back to text
        else if itemProvider.hasItemConformingToTypeIdentifier(UTType.plainText.identifier) {
            itemProvider.loadItem(forTypeIdentifier: UTType.plainText.identifier, options: nil) { [weak self] (item, error) in
                guard let self = self else { return }
                if let text = item as? String {
                    self.processExtractedText(text)
                }
            }
        }
    }
    
    private func processExtractedText(_ text: String) {
        // Store the URL
        sharedURL = text
        
        // Update UI on main thread
        DispatchQueue.main.async { [weak self] in
            guard let self = self else { return }
            self.textView.text = text
        }
    }
    
    private func presentCustomInterface(with urlString: String) {
        // Create the network manager and view model
        let networkManager = NetworkManager()
        let viewModel = ShareExtensionViewModel(networkManager: networkManager, url: urlString)
        
        // Create the SwiftUI view
        let shareExtensionView = ShareExtensionView(viewModel: viewModel)
        
        // Create a hosting controller
        let hostingController = UIHostingController(rootView: shareExtensionView)
        
        // Present the hosting controller
        hostingController.modalPresentationStyle = .fullScreen
        self.present(hostingController, animated: true, completion: nil)
    }
    
    // Override the post method to handle the share action
    override func didSelectPost() {
        if let urlString = sharedURL {
            // Save the URL to UserDefaults so the main app can access it
            let sharedDefaults = UserDefaults(suiteName: Constants.appGroupIdentifier)
            sharedDefaults?.set(urlString, forKey: Constants.userDefaultShareKey)
            
            // Try to send directly if possible
            Task {
                do {
                    let networkManager = NetworkManager()
                    try await networkManager.sendData(url: urlString)
                    // Success - clear from UserDefaults
                    sharedDefaults?.removeObject(forKey: Constants.userDefaultShareKey)
                } catch {
                    // Failed - leave in UserDefaults for main app to retry
                    print("Error sending URL: \(error.localizedDescription)")
                }
                
                // Close the extension
                DispatchQueue.main.async { [weak self] in
                    self?.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
                }
            }
        } else {
            // No URL to share, just close
            self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
        }
    }
    
    override func didSelectCancel() {
        // User canceled - just close the extension
        self.extensionContext?.completeRequest(returningItems: [], completionHandler: nil)
    }
    
    // Add configuration options in the share sheet
    override func configurationItems() -> [Any]! {
        // Create a configuration item
        let downloadToggle = SLComposeSheetConfigurationItem()
        downloadToggle?.title = "Download Immediately"
        downloadToggle?.value = "On"  // Default value
        downloadToggle?.tapHandler = {
            // Toggle the value
            if downloadToggle?.value == "On" {
                downloadToggle?.value = "Off"
            } else {
                downloadToggle?.value = "On"
            }
        }
        
        return [downloadToggle!]
    }
}
