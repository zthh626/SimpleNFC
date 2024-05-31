//
//  Alert.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-24.
//

import SwiftUI

struct AlertItem: Identifiable {
    let id = UUID()
    let title: Text
    let message: Text
    let dismissButton: Alert.Button
}

struct AlertContext {
    static let readingUnavailable           = AlertItem(title: Text("Unable to Read NFCs"),
                                                          message: Text("Please enable reading NFCs through the app."),
                                                          dismissButton: .default(Text("OK")))
    static let sessionInvalidated           = AlertItem(title: Text("Session Invalidated"),
                                                          message: Text("Please try again."),
                                                          dismissButton: .default(Text("OK")))
    static let nfcPayloadInvalidated        = AlertItem(title: Text("Empty Payload"),
                                                          message: Text("Please add a payload."),
                                                          dismissButton: .default(Text("OK")))
    static let nfcIdentiferInvalidated      = AlertItem(title: Text("Empty Identifier"),
                                                          message: Text("Please add an identifier."),
                                                          dismissButton: .default(Text("OK")))
    static let failedToSave                 = AlertItem(title: Text("Failed to save"),
                                                          message: Text("Please try again."),
                                                          dismissButton: .default(Text("OK")))
}
