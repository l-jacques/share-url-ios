//
//  NetworkShareURL.swift
//  share-api
//
//  Created by Laurent Jacques on 13/02/2025.
//


public protocol NetworkShareURL {
    func postUserData(data: ShareData) async throws -> String
    func sendData(url: String) async throws
}