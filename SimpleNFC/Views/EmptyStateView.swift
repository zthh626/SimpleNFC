//
//  EmptyView.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-29.
//

import SwiftUI

struct EmptyStateView: View {
    var body: some View {
        VStack (spacing: 20) {
            Image(systemName: "shippingbox.circle")
                .resizable()
                .frame(width: 100, height: 100)
            Text("Create new NFC Data to get started")
                .frame(width: 200)
                .multilineTextAlignment(.center)
        }
    }
}

#Preview {
    EmptyStateView()
}
