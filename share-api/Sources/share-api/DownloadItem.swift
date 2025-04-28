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
    public let resolution: String?
    public let url: String?
    
    public init(
        ended: String,
        errored: String?,
        filePath: String,
        started: String,
        status: String,
        title: String,
        resolution: String? = nil,
        url: String? = nil
    ) {
        self.ended = ended
        self.errored = errored
        self.filePath = filePath
        self.started = started
        self.status = status
        self.title = title
        self.resolution = resolution
        self.url = url
    }
}
