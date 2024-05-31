//
//  DetailedNFCView.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-28.
//

import SwiftUI
import CoreNFC

struct DetailedNFCView: View {
    @Binding var isActive: Bool
    
    @Environment(\.managedObjectContext) private var viewContext
    @StateObject private var viewModel = DetailedNFCViewModel()
    
    @EnvironmentObject var currentNDEFMessage: CurrentNDEFMessage

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            Text("NFC Data")
                .font(.title)
                .padding(.bottom, 10)
            
            if viewModel.record != nil {
                Form {
                    Section(header: Text("Identification")) {
                        TextField("Payload Identifier", text: Binding(
                            get: {
                                String(data: viewModel.identifier, encoding: .utf8) ?? "N/A"
                            },
                            set: { newValue in
                                if let newData = newValue.data(using: .utf8) {
                                    viewModel.identifier = newData
                                }
                            }
                        ))
                    }
                    
                    Section(header: Text("Payload Type")) {
                        Picker("Format", selection: Binding(
                            get: {
                                viewModel.payloadTypeNameFormat
                            },
                            set: { newValue in
                                print(newValue)
                                viewModel.payloadTypeNameFormat = newValue
                            }
                        )) {
                            ForEach(typeNameFormats, id: \.self) { format in
                                Text(format.description)
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                        
                        Picker("Type", selection: Binding(
                            get: {
                                String(data: viewModel.recordType, encoding: .utf8) ?? "N/A"
                            },
                            set: { newValue in
                                if let newData = newValue.data(using: .utf8) {
                                    viewModel.recordType = newData
                                }
                            }
                        )) {
                            ForEach(recordTypes) { type in
                                Text("\(type.description)")
                            }
                        }
                        .pickerStyle(MenuPickerStyle())
                    }
                    
                    Section(header: Text("Payload"))
                    {
                        TextEditor(text: Binding(
                            get: {
                                String(data: viewModel.payload, encoding: .utf8) ?? "N/A"
                            },
                            set: { newValue in
                                if let newData = newValue.data(using: .utf8) {
                                    viewModel.payload = newData
                                }
                            }
                        ))
                        .frame(height: 100)
                    }
                    Button {
                        viewModel.saveChanges(context: viewContext, currentNDEFMessage: currentNDEFMessage)
                    } label: {
                        Text("Save NFC Data")
                    }
                }
                .cornerRadius(10)
            } else {
                Text("No NFC record available.")
            }
        }
        .padding()
        .background(Color(.systemBackground))
        .cornerRadius(10)
        .onAppear {
            if let record = currentNDEFMessage.ndefMessage?.records.first {
               viewModel.record = record
               viewModel.identifier = record.identifier
               viewModel.payloadTypeNameFormat = record.typeNameFormat
               viewModel.recordType = record.type
               viewModel.payload = record.payload
            }
        }
        .alert(item: $viewModel.alertItem) { alertItem in
            Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
        }
        .onChange(of: viewModel.savedSuccessfully) { isSaved in
            if viewModel.savedSuccessfully {
                isActive = false
            }
        }
    }
}

#Preview {
    DetailedNFCView(isActive: .constant(true))
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(CurrentNDEFMessage())
}
