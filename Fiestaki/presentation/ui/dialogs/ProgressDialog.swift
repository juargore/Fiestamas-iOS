//
//  ProgressDialog.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 12/18/23.
//

import Foundation
import SwiftUI

struct ProgressDialog: View {
    
    var isVisible: Bool
    var message: String = "Procesando..."
    
    var body: some View {
        if isVisible {
            ZStack {
                Color.white
                    .cornerRadius(30)
                
                VStack {
                    ProgressView {
                        Text(message)
                            .foregroundColor(Color.black)
                            .font(.system(size: 17))
                            .padding(.top, 10)
                    }
                    .tint(Color.hotPink)
                    .controlSize(.large)
                }
            }
            .frame(width: 250, height: 150)
        }
    }
}

struct ProgressDialogPreview: PreviewProvider {
    static var previews: some View {
        ProgressDialog(isVisible: true)
    }
}
