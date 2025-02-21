//
//  AccessDataProtocol.swift
//  share-url
//
//  Created by Laurent Jacques on 21/02/2025.
//

protocol AccessDataProtocol {
    func save(key: String, value: String)
    func load(key: String) -> String?
}
