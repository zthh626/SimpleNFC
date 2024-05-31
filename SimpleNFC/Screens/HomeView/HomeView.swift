//
//  ContentView.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-24.
//

import SwiftUI
import CoreData

struct HomeView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @EnvironmentObject var currentNDFMessage: CurrentNDEFMessage
    @StateObject private var viewModel: HomeViewModel = HomeViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                VStack(spacing: 40) {
                    HStack {
                        Spacer()
                        ToggleModeView(isToggled: $viewModel.isReading)
                    }
                    .padding(.horizontal)
                    
                    if viewModel.isReading {
                        Spacer()
                    }
                    
                    ZStack {
                        Circle()
                            .stroke(lineWidth: 3)
                            .frame(width: 200)
                        Image("nfc-icon")
                            .resizable()
                            .frame(width: 130, height: 130)
                    }
                    .shadow(radius: 5)
                    .padding(.bottom, viewModel.isReading ? 200 : 0)
                    .onTapGesture {
                        viewModel.beginScanning()
                    }
                    
                    Spacer()
                    
                    if !viewModel.isReading {
                        VStack {
                            HStack {
                                Spacer()
                                Button {
                                    currentNDFMessage.setNewNFCNDEFMessage()
                                    viewModel.isDetailedViewOpen = true
                                } label: {
                                    Text("Create")
                                }
                            }
                            if viewModel.items.isEmpty {
                                EmptyStateView()
                                    .background()
                                    .onTapGesture {
                                        currentNDFMessage.setNewNFCNDEFMessage()
                                        viewModel.isDetailedViewOpen = true
                                    }
                            } else {
                                List {
                                    ForEach(viewModel.items, id: \.self.id) { item in
                                        NFCDataCellView(item: item, isSelected: currentNDFMessage.nfcData?.id == item.id)
                                            .background()
                                            .onTapGesture {
                                                currentNDFMessage.setNDEFMessageFromDB(item: item)
                                            }
                                            .swipeActions {
                                                Button(role: .destructive) {
                                                    if let index = viewModel.items.firstIndex(where: { $0.id == item.id }) {
                                                        viewModel.deleteItems(at: IndexSet(integer: index), context: viewContext)
                                                    }
                                                } label: {
                                                    Label("Delete", systemImage: "trash")
                                                }
                                                Button {
                                                    currentNDFMessage.setNDEFMessageFromDB(item: item)
                                                    currentNDFMessage.editUUID = item.id
                                                    viewModel.isDetailedViewOpen = true
                                                } label: {
                                                    Label("Edit", systemImage: "pencil")
                                                }
                                            }
                                    }
                                }
                                .listStyle(InsetGroupedListStyle())
                            }
                            
                            
                        }
                    }
                }
                .padding()
                
                NavigationLink(destination: DetailedNFCView(isActive: $viewModel.isDetailedViewOpen), isActive: $viewModel.isDetailedViewOpen) {
                    EmptyView()
                }
            }
            .navigationTitle("Simple NFC")
            .onAppear {
                viewModel.currentNDEFMessage = currentNDFMessage
                viewModel.fetchItems(context: viewContext)
            }
            .alert(item: $viewModel.alertItem) { alertItem in
                Alert(title: alertItem.title, message: alertItem.message, dismissButton: alertItem.dismissButton)
            }
        }
    }
}

#Preview {
    HomeView()
        .environment(\.managedObjectContext, PersistenceController.preview.container.viewContext)
        .environmentObject(CurrentNDEFMessage())
}
