//
//  StatusViewModel.swift
//  share-url
//
//  Created by Laurent Jacques on 12/02/2025.
//
import Foundation
import share_api

class StatusViewModel: ObservableObject {
    @Published public var shareData: [ShareData] = []
    
}
