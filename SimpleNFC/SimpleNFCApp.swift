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

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environment(\.managedObjectContext, persistenceController.container.viewContext)
        }
    }
}
