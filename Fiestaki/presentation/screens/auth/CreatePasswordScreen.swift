//
//  SignUpScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 18/05/23.
//

import SwiftUI

struct CreatePasswordScreen: View {

    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: AuthNavGraph
    
    var email: String
    
    @State private var password: String = ""
    @State private var confirmPassword: String = ""
    @State private var showToast = false
    @State private var messageToast = ""
    
    @State private var acceptTerms = false
    @State private var receiveDiscounts = false
    @State private var wantToBeProvider = false
    
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
                    ScrollView(.vertical) {
                        VStack {
                            HStack {
                                Text("Crear una contraseña")
                                    .font(.midRegular)
                                    .fontWeight(.w800)
                                    .foregroundColor(.black)
                                    .padding(.top, 16)

                                Spacer()
                            }

                            HStack {
                                Text("Para \(email)")
                                    .font(.overNormal)
                                    .fontWeight(.w500)
                                    .foregroundColor(.black)
                                    .minimumScaleFactor(0.7)

                                Spacer()
                            }

                            HStack {
                                Text("Usa un mínimo de 8 carateres que incuyen mayúsculas, minúsculas, números y símbolos.")
                                    .font(.small)
                                    .fontWeight(.w400)
                                    .minimumScaleFactor(0.7)
                                    .lineLimit(3)
                                    .foregroundColor(.black)
                                    .frame(minHeight: 60, maxHeight: 100)

                                Spacer()
                            }
                            
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
                            
                            ZStack {
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: 1)
                                    .frame(height: 50)
                                    .foregroundColor(.gray.opacity(0.5))
                                
                                PasswordTextField(placeholderText: "", passwordText: $confirmPassword)
                                    .frame(height: 50)
                                    .foregroundColor(.black)
                                    .placeholder("Confirmar Contraseña", when: confirmPassword.isEmpty)
                            }
                            
                            ZStack { // start first checkbox
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(height: 50)
                                    .foregroundColor(Color.iceBlue.opacity(0.3))

                                HStack(spacing: 8) {
                                    Button {
                                        acceptTerms.toggle()
                                    } label: {
                                        if acceptTerms {
                                            Image(systemName: "checkmark.square.fill")
                                                .font(.medium)
                                                .foregroundColor(.hotPink)
                                        } else {
                                            Image(systemName: "square")
                                                .font(.medium)
                                                .foregroundColor(.hotPink)
                                        }
                                    }
                                    .padding(.leading, 10)

                                    Group {
                                        Text("Acepto los ")
                                            .font(.tiny)
                                            .fontWeight(.w400) +
                                        Text("Términos y condiciones")
                                            .font(.tiny)
                                            .fontWeight(.w400)
                                            .foregroundColor(.hotPink) +
                                        Text(" y la ")
                                            .font(.tiny)
                                            .fontWeight(.w400) +
                                        Text("Política de privacidad")
                                            .font(.tiny)
                                            .fontWeight(.w400)
                                            .foregroundColor(.hotPink)
                                    }
                                    .padding(.horizontal, 10)

                                    Spacer()
                                }
                            } // end first checkbox
                            .padding(.bottom, 2)
                            .padding(.top, 15)
                            
                            /*
                            ZStack { // start second checkbox
                                RoundedRectangle(cornerRadius: 8)
                                    .frame(height: 50)
                                    .foregroundColor(Color.iceBlue.opacity(0.3))

                                HStack(spacing: 8) {

                                    Button {
                                        receiveDiscounts.toggle()
                                    } label: {
                                        if receiveDiscounts {
                                            Image(systemName: "checkmark.square.fill")
                                                .font(.medium)
                                                .foregroundColor(.hotPink)
                                        } else {
                                            Image(systemName: "square")
                                                .font(.medium)
                                                .foregroundColor(.hotPink)
                                        }
                                    }
                                    .padding(.leading, 10)

                                    Text("Quiero recibir promociones y descuentos de FIESTAKI.")
                                        .font(.tiny)
                                        .fontWeight(.w400)
                                        .padding(.horizontal, 8)

                                    Spacer()
                                }
                            } // end second checkbox
                            .padding(.vertical, 4)
                            */
                            
                            ZStack { // start third checkbox
                                RoundedRectangle(cornerRadius: 8)
                                    .stroke(lineWidth: 2)
                                    .frame(height: 50)
                                    .foregroundColor(Color.iceBlue.opacity(0.3))

                                HStack(spacing: 8) {

                                    Button {
                                        wantToBeProvider.toggle()
                                    } label: {
                                        if wantToBeProvider {
                                            Image(systemName: "checkmark.square.fill")
                                                .font(.medium)
                                                .foregroundColor(.hotPink)
                                        } else {
                                            Image(systemName: "square")
                                                .font(.medium)
                                                .foregroundColor(.hotPink)
                                        }
                                    }
                                    .padding(.leading, 10)

                                    Text("Quiero ser Proveedor")
                                        .font(.midRegular)
                                        .fontWeight(.w800)
                                        .foregroundColor(.black)
                                        .padding(.horizontal, 8)

                                    Spacer()
                                }
                            } // end third checkbox
                            .padding(.top, 4)
                            .padding(.bottom, 20)
                            
                            FiestakiButton(text: "Crear una cuenta") {
                                if isValidPassword(password) {
                                    if password == confirmPassword {
                                        if acceptTerms == true {
                                            let loginAccount = LoginAccount(email: email, password: password)
                                            if wantToBeProvider {
                                                navigation.navigate(to: .onNavigateToCreateProvider(loginAccount))
                                            } else {
                                                navigation.navigate(to: .onNavigateToCreateUser(loginAccount))
                                            }
                                        } else {
                                            messageToast = "Por favor acepte los Términos y Condiciones"
                                            showToast = true
                                        }
                                    } else {
                                        messageToast = "Las contraseñas no coinciden"
                                        showToast = true
                                    }
                                } else {
                                    messageToast = "Verifique el formato de la contraseña"
                                    showToast = true
                                }
                            }
                        }
                        .padding()
                    }
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
