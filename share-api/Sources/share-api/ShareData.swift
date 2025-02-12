//
//  Data.swift
//  share-url
//
//  Created by Laurent Jacques on 10/02/2025.
//
import Foundation

public struct ShareData: Codable, Identifiable  {
    public let id: UUID
    
    public let url: String
    public let name: String?
    public let status: String?
    
    public init(id: UUID = UUID(), url: String, name: String? = nil, status: String? = nil) {
        self.id = id
        self.url = url
        self.name = name
        self.status = status
    }
}
