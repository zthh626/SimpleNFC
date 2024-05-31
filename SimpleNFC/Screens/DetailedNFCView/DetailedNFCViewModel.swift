//
//  DetailedNFCViewModel.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-28.
//

import SwiftUI
import CoreNFC
import CoreData

let typeNameFormats: [NFCTypeNameFormat] = [.empty, .nfcWellKnown, .media, .absoluteURI, .nfcExternal, .unknown, .unchanged]

struct RecordType: Identifiable {
    let id: String
    let description: String
    var idAndDescription: String { "\(id) - \(description)" }
}

let recordTypes: [RecordType] = [
    RecordType(id: "T", description: "Text"),
    RecordType(id: "U", description: "URI"),
    RecordType(id: "Sp", description: "Smart Poster"),
    RecordType(id: "M", description: "Media")
]

final class DetailedNFCViewModel: ObservableObject {
    @Published var record: NFCNDEFPayload?
    @Published var identifier: Data = Data()
    @Published var payloadTypeNameFormat: NFCTypeNameFormat = .unknown
    @Published var recordType: Data = Data()
    @Published var payload: Data = Data()
    
    @Published var alertItem: AlertItem?
    
    @Published var savedSuccessfully = false
    
    var isValid: Bool {
        guard !identifier.isEmpty else {
            alertItem = AlertContext.nfcIdentiferInvalidated
            return false
        }
        
        guard !payload.isEmpty else {
            alertItem = AlertContext.nfcPayloadInvalidated
            return false
        }
        
        return true
    }
    
    func saveChanges(context: NSManagedObjectContext, currentNDEFMessage: CurrentNDEFMessage) {
        guard isValid else {
            return
        }
        
        var item: NFCData
        
        if (currentNDEFMessage.editUUID != nil && currentNDEFMessage.nfcData != nil) {
            item = currentNDEFMessage.nfcData!
            item.last_accessed = Date()
        } else {
            item = NFCData(context: context)
            item.id = UUID()
            item.timestamp = Date()
            item.last_accessed = Date()
        }
        
        item.identifier = self.identifier
        item.format = Int16(self.payloadTypeNameFormat.rawValue)
        item.record_type = self.recordType

        item.payload = self.payload
        
        do {
            try context.save()
            
            currentNDEFMessage.editUUID = nil
            currentNDEFMessage.nfcData = nil
        } catch {
            alertItem = AlertContext.failedToSave
            return
        }
    
        
        self.savedSuccessfully = true
    }
}
