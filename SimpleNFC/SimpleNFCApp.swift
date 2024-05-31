//
//  SimpleNFCApp.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-24.
//

import SwiftUI

@main
struct SimpleNFCApp: App {
    let persistenceController = PersistenceController.shared
    let currentNDEFMessage = CurrentNDEFMessage()

    var body: some Scene {
        WindowGroup {
            HomeView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
                .environmentObject(currentNDEFMessage)
        }
    }
}
