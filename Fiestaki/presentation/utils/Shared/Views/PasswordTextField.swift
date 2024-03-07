//
//  PasswordTextField.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 22/05/23.
//

import SwiftUI

struct PasswordTextField: View {

    @FocusState var focus1: Bool
    @FocusState var focus2: Bool
    @State var showPassword: Bool = false
    var placeholderText: String
    @Binding var passwordText: String

    var body: some View {
        HStack{
            secureField()
            if !passwordText.isEmpty {

                Button {
                    self.showPassword.toggle()
                } label: {
                    ZStack(alignment: .trailing){
                        Color.clear
                            .frame(maxWidth: 29, maxHeight: 60, alignment: .center)
                        Image(systemName: self.showPassword ? "eye.fill" : "eye.slash.fill")
                            .font(.system(size: 18, weight: .medium))
                            .foregroundColor(Color.init(red: 160.0/255.0, green: 160.0/255.0, blue: 160.0/255.0))
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }

    @ViewBuilder
    func secureField() -> some View {
        if self.showPassword {
            TextField(placeholderText, text: $passwordText)
                .font(.overNormal)
                .fontWeight(.w600)
                .keyboardType(.default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        } else {
            SecureField(placeholderText, text: $passwordText)
                .font(.overNormal)
                .fontWeight(.w600)
                .keyboardType(.default)
                .autocapitalization(.none)
                .disableAutocorrection(true)
        }
    }
}

struct PasswordTextField_Previews: PreviewProvider {
    static var previews: some View {
        PasswordTextField( placeholderText: "" ,passwordText: .constant(""))
    }
}
