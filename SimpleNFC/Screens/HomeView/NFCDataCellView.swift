//
//  NFCDataCellView.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-28.
//

import SwiftUI

struct NFCDataCellView: View {
    
    var item: NFCData
    var isSelected: Bool
    
    var body: some View {
        HStack {
            VStack(alignment: .leading) {
                Text("\(String(data: (item.identifier ?? Data()) , encoding: .utf8) ?? "N/A")")
                    .font(.headline)
                Text("Created On: \(item.timestamp ?? Date(), formatter: itemFormatter)")
                    .font(.subheadline)
            }
            Spacer()
            if isSelected {
                Image(systemName: "checkmark.circle.fill")
                    .foregroundColor(.blue)
            }
        }
        .padding()
    }
}

private let itemFormatter: DateFormatter = {
    let formatter = DateFormatter()
    formatter.dateStyle = .short
    return formatter
}()
