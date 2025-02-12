//
//  Data.swift
//  share-url
//
//  Created by Laurent Jacques on 10/02/2025.
//

public struct ShareData: Codable {
    let url: String
    let name: String?
    let status: String?
    
    public init(url: String, name: String? = nil, status: String? = nil) {
        self.url = url
        self.name = name
        self.status = status
    }
}
