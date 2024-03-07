//
//  NewExpressQuoteOrEditDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/21/23.
//

import Foundation
import SwiftUI

struct NewExpressQuoteOrEditDialog: View {
    
    var isEditingData: Bool
    var originalTotal: String
    var originalNotes: String
    var onSendNewQuoteClicked: (
        String, /// notes
        Int /// total
    ) -> Void
    var onEditQuoteClicked: (
        String, /// notes
        Int /// total
    ) -> Void
    var onDismiss: () -> Void
    
    @State private var importantNotes: String
    @State private var total: String
    
    init(
        isEditingData: Bool,
        originalTotal: String,
        originalNotes: String,
        onSendNewQuoteClicked: @escaping (String, Int) -> Void,
        onEditQuoteClicked: @escaping (String, Int) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.isEditingData = isEditingData
        self.originalTotal = originalTotal
        self.originalNotes = originalNotes
        self.onSendNewQuoteClicked = onSendNewQuoteClicked
        self.onEditQuoteClicked = onEditQuoteClicked
        self.onDismiss = onDismiss
        
        importantNotes = originalNotes
        total = originalTotal
    }
    
    var body: some View {
        VStack {
            HStack {
                Spacer()
                Text("X")
                    .foregroundColor(.black)
            }.onTapGesture {
                onDismiss()
            }
            
            Text(isEditingData ? "Editar Cotización Express" : "Nueva Cotización Express")
                .fontWeight(.semibold)
                .font(.system(size: 19))
                .foregroundColor(.black)
            
            Divider()
                .padding(.vertical, 12)
            
            HStack {
                Text("Notas importantes")
                    .font(.tiny)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            
            TextField("", text: $importantNotes, axis: .vertical)
                .font(.body)
                .lineLimit(5, reservesSpace: true)
                .background(Color.white)
                .cornerRadius(8)
                .multilineTextAlignment(.center)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .foregroundColor(.black)
                .padding(10)
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.ashGray, lineWidth: 0.8))
            
            HStack {
                Text("Precio")
                    .font(.tiny)
                    .foregroundColor(Color.gray)
                Spacer()
            }
            .padding(.top, 6)
            
            HStack {
                TextField("", text: $total)
                    .font(.body)
                    .frame(height: 50)
                    .background(Color.white)
                    .cornerRadius(8)
                    .multilineTextAlignment(.center)
                    .disabled(true)
                    .foregroundColor(.black)
                    .padding(10)
                    .clipShape(RoundedRectangle(cornerRadius: 15))
                    .overlay(RoundedRectangle(cornerRadius: 15)
                        .stroke(Color.ashGray, lineWidth: 0.8))
                
                FiestakiButton(
                    text: "Enviar",
                    customCorner: 15,
                    action: {
                        if !total.isEmpty {
                            if isEditingData {
                                onEditQuoteClicked(importantNotes, Int(total) ?? 0)
                            } else {
                                onSendNewQuoteClicked(importantNotes, Int(total) ?? 0)
                            }
                        }
                    }
                )
            }
        }
        .padding()
    }
}
