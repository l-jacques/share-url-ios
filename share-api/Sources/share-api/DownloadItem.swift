//
//  DownloadItem.swift
//  share-api
//
//  Created by Laurent Jacques on 13/02/2025.
//


import Foundation

public struct DownloadItem: Codable, Sendable {
    public let ended: String
    public let errored: String?
    public let filePath: String
    public let started: String
    public let status: String
    public let title: String
}
