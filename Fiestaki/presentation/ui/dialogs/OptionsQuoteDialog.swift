//
//  OptionsQuoteDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/21/23.
//

import Foundation
import SwiftUI

struct OptionsQuoteDialog: View {
    
    var onActionSelected: (OptionsQuote) -> Void
    var onDismiss: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("X")
                    .foregroundColor(.black)
            }.onTapGesture {
                onDismiss()
            }
            
            Text("Opciones de cotización")
                .fontWeight(.semibold)
                .font(.system(size: 18))
            
            Divider()
                .padding(.vertical, 12)
            
            HStack {
                VStack {
                    Text("Contratado")
                        .padding()
                        .foregroundColor(.black)
                }
                .background(Color(UIColor(hex: "#AFDAB1")))
                .cornerRadius(16)
                .onTapGesture {
                    onActionSelected(OptionsQuote.Hired)
                }
                
                Spacer()
                
                VStack {
                    Text("Pendiente")
                        .padding()
                        .foregroundColor(.black)
                }
                .background(Color(UIColor(hex: "#FFF14C")))
                .cornerRadius(16)
                .onTapGesture {
                    onActionSelected(OptionsQuote.Pending)
                }
                
                Spacer()
                
                VStack {
                    Text("Cancelar")
                        .padding()
                        .foregroundColor(.black)
                }
                .background(Color(UIColor(hex: "#F9AA8F")))
                .cornerRadius(16)
                .onTapGesture {
                    onActionSelected(OptionsQuote.Cancel)
                }
            }
        }
        .padding()
    }
}
