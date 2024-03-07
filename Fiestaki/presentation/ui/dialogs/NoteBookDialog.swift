//
//  NoteBookDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/21/23.
//

import Foundation
import SwiftUI


struct NoteBookDialog: View {
    
    var isEditable: Bool
    var onSaveClicked: (String) -> Void
    var onDismiss: () -> Void
    
    @State var notes: String
    @State var title: String
    
    init(
        savedNotes: String,
        isEditable: Bool,
        onSaveClicked: @escaping (String) -> Void,
        onDismiss: @escaping () -> Void
    ) {
        self.isEditable = isEditable
        self.onSaveClicked = onSaveClicked
        self.onDismiss = onDismiss
        
        notes = savedNotes
        title = "Notas importantes"
        if isEditable {
            title = "Block de notas"
        }
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
            
            Text(title)
                .fontWeight(.semibold)
                .font(.system(size: 18))
                .foregroundColor(.black)
            
            Divider()
                .padding(.vertical, 12)
            
            TextField("", text: $notes, axis: .vertical)
                .font(.body)
                .lineLimit(5, reservesSpace: true)
                .background(Color.white)
                .cornerRadius(8)
                .disabled(!isEditable)
                .multilineTextAlignment(.center)
                .foregroundColor(.black)
                .clipShape(RoundedRectangle(cornerRadius: 15))
                .overlay(RoundedRectangle(cornerRadius: 15)
                    .stroke(Color.ashGray, lineWidth: 0.8))
            
            if isEditable {
                HStack {
                    Spacer()
                    FiestakiButton(text: "Guardar", customCorner: 12, action: {
                        onSaveClicked(notes)
                    })
                }
            }
        }
        .padding()
    }
}
