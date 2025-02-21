//
//  SettingsViewModelProtocol.swift
//  share-url
//
//  Created by Laurent Jacques on 21/02/2025.
//

protocol SettingsViewModelProtocol {
    var serverUrl: String { get set}
    func saveServerUrl(_ url: String)
}
