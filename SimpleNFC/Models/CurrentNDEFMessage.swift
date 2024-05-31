//
//  CurrentNDEFMessage.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-28.
//

import Foundation
import CoreNFC
import CoreData

final class CurrentNDEFMessage: ObservableObject {
    @Published var ndefMessage: NFCNDEFMessage?
    @Published var nfcData: NFCData?
    @Published var editUUID: UUID?
    
    func setNDEFMessageFromDB(item: NFCData) {
        guard let recordType = item.record_type,
              let identifier = item.identifier,
              let payload = item.payload,
              let format = NFCTypeNameFormat(rawValue: UInt8(item.format)) else {
            return
        }
        
        if format == .absoluteURI ||  format == .absoluteURI || String(data: recordType, encoding: .utf8) == "U" {
            ndefMessage = NFCNDEFMessage(records: [NFCNDEFPayload.wellKnownTypeURIPayload(string: String(data: payload, encoding: .utf8)!)!])
        } else if String(data: recordType, encoding: .utf8) == "T" {
            ndefMessage = NFCNDEFMessage(records: [NFCNDEFPayload.wellKnownTypeTextPayload(string: String(data: payload, encoding: .utf8)!, locale: .current)!])
        } else {
            ndefMessage = NFCNDEFMessage(records: [NFCNDEFPayload(format: format, type: recordType, identifier: identifier, payload: payload)])
        }
        
        ndefMessage?.records[0].identifier = identifier

        nfcData = item
    }
    
    func setNewNFCNDEFMessage() {
        ndefMessage = NFCNDEFMessage(records: [NFCNDEFPayload(format: NFCTypeNameFormat(rawValue: 1)!, type: "T".data(using: .utf8)!, identifier: Data(), payload: Data())])
    }
}

extension NFCTypeNameFormat: Identifiable {
    public var id: UInt8 { self.rawValue }
    var description: String {
        switch self {
        case .empty: return "Empty"
        case .nfcWellKnown: return "NFC Well Known"
        case .media: return "Media"
        case .absoluteURI: return "Absolute URI"
        case .nfcExternal: return "NFC External"
        case .unknown: return "Unknown"
        case .unchanged: return "Unchanged"
        @unknown default: return "Unknown"
        }
    }
}

