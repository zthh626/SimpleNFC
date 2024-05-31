//
//  ToggleOptionView.swift
//  SimpleNFC
//
//  Created by Alex on 2024-05-26.
//

import SwiftUI

struct ToggleModeView: View {
    
    @Binding var isToggled: Bool
    
    var body: some View {
        ZStack {
            Capsule()
                .frame(width: 140, height: 50)
                .foregroundColor(.blue)
            
            HStack {
                if(isToggled) {
                    Spacer()
                }
                Capsule()
                    .frame(width: 60, height: 40)
                    .foregroundColor(.white)
                    .opacity(0.6)
                if(!isToggled) {
                    Spacer()
                }
            }
            .padding(.leading, 8)
            .padding(.trailing, 5)
                
            HStack {
                Text("Write")
                Spacer()
                Text("Read")
            }
            .padding()
            .foregroundColor(.white)
        }
        .frame(width: 140, height: 50)
        .onTapGesture {
            withAnimation {
                isToggled.toggle()
            }
        }
    }
}

#Preview {
    ToggleModeView(isToggled: .constant(false))
}
