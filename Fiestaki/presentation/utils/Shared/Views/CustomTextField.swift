//
//  CustomTextField.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 22/05/23.
//

import SwiftUI

struct CustomTextField: View {

    var placeholder: String
    @Binding var text: String
    //var onTextChanged: ((String) -> Void)? = nil

    var body: some View {
        ZStack {
            TextField("", text: $text)
                .fontWeight(.w500)
                .font(.system(size: 18))
                .frame(height: 55)
                .padding(.horizontal, 16)
                .overlay(
                    RoundedRectangle(cornerRadius: 8)
                        .strokeBorder(Color.gray, lineWidth: 0.8)
                )
                .foregroundColor(.black)
                .placeholder(placeholder, when: text.isEmpty)
                /*.onChange(of: text) { newValue in
                    // Cada vez que el texto cambia, se ejecuta este bloque
                    print("Nuevo valor del TextField: \(newValue)")
                    // Puedes realizar cualquier acción que desees aquí
                }*/
        }
    }
}

struct CustomTextField_Previews: PreviewProvider {
    static var previews: some View {
        CustomTextField(placeholder: "placeholder", text: .constant(""))
    }
}
