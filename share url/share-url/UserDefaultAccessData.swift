//
//  UserDefaultAccessData.swift
//  share-url
//
//  Created by Laurent Jacques on 21/02/2025.
//
import Foundation

class UserDefaultAccessData: AccessDataProtocol {
    
    func save(key: String, value: String) {
        //from user default
        UserDefaults.standard.set(value, forKey: "key")
    }
    
    func load(key: String) -> String? {
        return UserDefaults.standard.string(forKey: "key")
    }
     
}
