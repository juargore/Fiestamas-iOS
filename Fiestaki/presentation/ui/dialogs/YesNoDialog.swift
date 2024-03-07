//
//  YesNoDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/21/23.
//

import Foundation
import SwiftUI

struct YesNoDialog: View {
    
    var title: String? = nil
    var message: String? = nil
    var addCancelButton = true
    var icon = "ic_success_circled"
    var onDismiss: () -> Void
    var onOk: () -> Void
    
    var body: some View {
        VStack {
            Image(icon)
                .resizable()
                .frame(width: 80, height: 80)
            if title != nil {
                Text(title!)
                    .fontWeight(.semibold)
                    .font(.system(size: 17))
                    .foregroundColor(.black)
            }
            if message != nil {
                Text(message!)
                    .font(.subheadline)
                    .foregroundColor(.black)
            }
            HStack {
                Spacer()
                if addCancelButton {
                    Text("Cancelar")
                        .foregroundColor(Color.ashGray)
                        .padding(.horizontal, 10)
                        .onTapGesture {
                            onDismiss()
                        }
                }
                Text("Aceptar")
                    .foregroundColor(Color.hotPink)
                    .onTapGesture {
                        onOk()
                    }
            }
            .padding(.vertical, 10)
        }
        .padding()
    }
}
