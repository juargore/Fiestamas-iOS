//
//  SignInScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 17/05/23.
//

import SwiftUI

struct LogInScreen: View {

    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: AuthNavGraph
    
    var loginAccount: LoginAccount
    
    @State private var email: String
    @State private var password: String
    @State private var showToast = false
    @State private var messageToast = ""
    @State private var rememberCredentials = true
    
    init(loginAccount: LoginAccount) {
        self.loginAccount = loginAccount
        self.email = loginAccount.email
        self.password = loginAccount.password
    }

    var body: some View {
        ZStack {
            backgroundLinearGradient()
            VStack {
                mainHeader(
                    userIsLoggedIn: false,
                    username: "",
                    showBackButton: true,
                    showNotificationIcon: false,
                    onBackButtonClicked: {
                        navigation.navigateBack()
                    }
                )
                
                ZStack {
                    VStack {
                        Text("Inicia sesión")
                            .font(.big)
                            .fontWeight(.w700)
                            .foregroundColor(.hotPink)
                            .padding(.top, 20)
                        
                        CustomTextField(placeholder: "E-mail", text: $email)
                            .padding(.all, 16)
                        
                        ZStack {
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(lineWidth: 1)
                                .frame(height: 50)
                                .foregroundColor(.gray.opacity(0.5))
                            
                            PasswordTextField(placeholderText: "", passwordText: $password)
                                .frame(height: 50)
                                .foregroundColor(.black)
                                .placeholder("Contraseña", when: password.isEmpty)
                        }
                        .padding(.horizontal, 16)
                        .padding(.bottom, 12)
                        
                        CheckboxFiestamas(text: "Guardar contraseña", startChecked: true) { checked in
                            rememberCredentials = checked
                        }
                        .padding(.bottom, 15)
                        .padding(.horizontal, 16)
                        
                        FiestakiButton(text: "Continuar") {
                            if email.isEmpty || password.isEmpty {
                                messageToast = "Llene los campos requeridos"
                                showToast = true
                            } else {
                                authViewModel.signInWithEmailAndPassword(
                                    email: email,
                                    password: password,
                                    validCredentials: { success in
                                        if success {
                                            messageToast = "Bienvenid@ \(email)"
                                            showToast = true
                                            
                                            if rememberCredentials {
                                                let data = LoginAccount(email: email, password: password)
                                                authViewModel.storeAccountIntoAppStorage(data: data)
                                            }
                                            
                                            navigation.navigateBack()
                                        } else {
                                            messageToast = "El Usuario y/o Contraseña son incorrectos. Verifique y vuelva a intentar"
                                            showToast = true
                                        }
                                    }
                                )
                            }
                        }
                        .padding(.bottom, 15)
                    }
                    .padding()
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.4), radius: 5)
                .padding()
                
                Spacer()
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .toolbar(.hidden)
    }
}
