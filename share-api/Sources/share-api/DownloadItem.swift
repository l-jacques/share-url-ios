//
//  DownloadItem.swift
//  share-api
//
//  Created by Laurent Jacques on 13/02/2025.
//


import Foundation

public struct DownloadItem: Codable, Sendable {
    public let id: String?
    public let ended: String?  // null while in progress or after an error
    public let errored: String?
    public let filePath: String
    public let started: String
    public let status: String
    public let title: String
    public let resolution: String?
    public let url: String?
    
    /// Stable key for lists: the server id when present (servers before Nov 2026 didn't send one).
    public var listID: String { id ?? "\(started)|\(url ?? title)" }

    public init(
        id: String? = nil,
        ended: String?,
        errored: String?,
        filePath: String,
        started: String,
        status: String,
        title: String,
        resolution: String? = nil,
        url: String? = nil
    ) {
        self.id = id
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
