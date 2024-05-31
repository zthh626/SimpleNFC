//
//  NFCViewController.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-24.
//

import SwiftUI
import CoreData
import CoreNFC

final class HomeViewModel: NSObject, ObservableObject {
    var currentNDEFMessage: CurrentNDEFMessage?
    var session: NFCNDEFReaderSession?
    
    @Published var items: [NFCData] = []
    @Published var isReading = false
    @Published var isDetailedViewOpen: Bool = false
    
    @Published var isEditingList: Bool = false
    
    var alertItem: AlertItem?
    
    override init() {
        super.init()
    }
    
    func fetchItems(context: NSManagedObjectContext) {
        let request: NSFetchRequest<NFCData> = NFCData.fetchRequest()
        request.sortDescriptors = [NSSortDescriptor(keyPath: \NFCData.timestamp, ascending: false)]
        
        do {
            items = try context.fetch(request)
            
            if !items.isEmpty {
                currentNDEFMessage?.setNDEFMessageFromDB(item: items[0])
            }
        } catch {
            print("Failed to fetch items: \(error)")
        }
    }
    
    func deleteItems(at offsets: IndexSet, context: NSManagedObjectContext) {
        withAnimation {
            offsets.map { items[$0] }.forEach(context.delete)
            
            do {
                try context.save()
            } catch {
                let nsError = error as NSError
                fatalError("Unresolved error \(nsError), \(nsError.userInfo)")
            }
            
            fetchItems(context: context)
        }
    }
    
    func beginScanning() {
        guard NFCNDEFReaderSession.readingAvailable else {
            alertItem = AlertContext.readingUnavailable
            return
        }
        
        session = NFCNDEFReaderSession(delegate: self, queue: nil, invalidateAfterFirstRead: true)
        session?.alertMessage = "Hold your iPhone near the item to learn more about it."
        session?.begin()
    }
}

extension HomeViewModel: NFCNDEFReaderSessionDelegate {
    func readerSession(_ session: NFCNDEFReaderSession, didDetect tags: [any NFCNDEFTag]) {
        if tags.count > 1 {
            // Restart polling in 500 milliseconds.
            let retryInterval = DispatchTimeInterval.milliseconds(500)
            session.alertMessage = "More than 1 tag is detected. Please remove all tags and try again."
            DispatchQueue.global().asyncAfter(deadline: .now() + retryInterval) {
                session.restartPolling()
            }
            return
        }
        
        let tag = tags.first!
        session.connect(to: tag) { error in
            if let error = error {
                session.alertMessage = "Unable to connect to tag: \(error.localizedDescription)"
                session.invalidate()
                return
            }
            
            tag.queryNDEFStatus { ndefStatus, capacity, error in
                guard error == nil else {
                    session.alertMessage = "Unable to query the NDEF status of tag."
                    session.invalidate()
                    return
                }
                
                switch ndefStatus {
                case .notSupported:
                    session.alertMessage = "Tag is not NDEF compliant."
                    session.invalidate()
                case .readOnly:
                    if self.isReading {
                        tag.readNDEF { message, error in
                            if let error = error {
                                session.alertMessage = "Read NDEF message fail: \(error.localizedDescription)"
                            } else {
                                DispatchQueue.main.async {
                                    self.currentNDEFMessage?.ndefMessage = message
                                    self.isDetailedViewOpen = true
                                }
                            }
                            session.invalidate()
                        }
                    } else {
                        session.alertMessage = "Tag is read-only."
                        session.invalidate()
                    }
                case .readWrite:
                    if self.isReading == false {
                        guard let message = self.currentNDEFMessage?.ndefMessage else {
                            session.alertMessage = "Write NDEF message failed, no message selected"
                            session.invalidate()
                            return
                        }
                        
                        tag.writeNDEF(message) { error in
                            if let error = error {
                                session.alertMessage = "Write NDEF message fail: \(error.localizedDescription)"
                            } else {
                                session.alertMessage = "Write NDEF message successful."
                            }
                            session.invalidate()
                        }
                    } else {
                        tag.readNDEF { message, error in
                            if let error = error {
                                session.alertMessage = "Read NDEF message fail: \(error.localizedDescription)"
                            } else {
                                DispatchQueue.main.async {
                                    self.currentNDEFMessage?.ndefMessage = message
                                    self.isDetailedViewOpen = true
                                }
                            }
                            session.invalidate()
                        }
                    }
                @unknown default:
                    session.alertMessage = "Unknown NDEF tag status."
                    session.invalidate()
                }
            }
        }
    }
    
    func readerSession(_ session: NFCNDEFReaderSession, didInvalidateWithError error: Error) {
        if let readerError = error as? NFCReaderError {
            // Show an alert when the invalidation reason is not because of a
            // successful read during a single-tag read session, or because the
            // user canceled a multiple-tag read session from the UI or
            // programmatically using the invalidate method call.
            if (readerError.code != .readerSessionInvalidationErrorFirstNDEFTagRead)
                && (readerError.code != .readerSessionInvalidationErrorUserCanceled) {
                DispatchQueue.main.async {
                    self.alertItem = AlertContext.sessionInvalidated
                }
            }
        }
        
        // To read new tags, a new session instance is required.
        self.session = nil
    }
    
    // MARK: https://developer.apple.com/documentation/corenfc/nfcndefreadersessiondelegate/2875568-readersession
    // The reader session doesn’t call this method when the delegate provides the readerSession(_:didDetect:) method.
    func readerSession(_ session: NFCNDEFReaderSession, didDetectNDEFs messages: [NFCNDEFMessage]) {
        return
    }
}
