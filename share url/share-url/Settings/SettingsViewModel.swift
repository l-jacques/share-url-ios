//
//  SettingsViewModel.swift
//  share-url
//
//  Created by Laurent Jacques on 21/02/2025.
//

import Foundation
import share_api

class SettingsViewModel : SettingsViewModelProtocol, ObservableObject {
    private let saveData: AccessDataProtocol
 
    @Published public var serverUrl: String
    
    func saveServerUrl(_ url: String) {
        serverUrl = url
        saveData.save(key: "serverUrl", value: url)
        print(url)
    }
    
    
    init(saveData: AccessDataProtocol) {
        self.saveData = saveData
        serverUrl = saveData.load(key: "serverUrl") ?? Constants.defaultServerURL
        print(serverUrl)
    }
}
