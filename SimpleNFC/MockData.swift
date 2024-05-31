//
//  MockData.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-28.
//

import SwiftUI
import CoreNFC
import CoreData

struct MockData {
    static let message = NFCNDEFMessage(records: [NFCNDEFPayload.wellKnownTypeURIPayload(url: URL(string: "https://open.spotify.com/track/40oKW22ZNNkEdZLJTScaQI?si=5cce4253e52f485e")!)!])
    static func generateDbItem() -> NFCData {
        let newItem = NFCData()
        
        newItem.id = UUID()
        newItem.timestamp = Date()
        newItem.last_accessed = Date()
        
        newItem.format = 1
        newItem.record_type = "exampleRecordType".data(using: .utf8)
        
        newItem.identifier = "exampleIdentifier".data(using: .utf8)
        newItem.payload = "examplePayload".data(using: .utf8)
        
        return newItem
    }
}
