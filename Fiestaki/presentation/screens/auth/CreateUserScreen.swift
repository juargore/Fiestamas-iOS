//
//  ClientInfoScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 18/05/23.
//

import SwiftUI

struct CreateUserScreen: View {
    
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: AuthNavGraph
    
    var loginAccount: LoginAccount
    
    @State private var name = ""
    @State private var lastName = ""
    @State private var mobilePhone = ""
    @State private var homePhone = ""
    @State private var showToast = false
    @State private var messageToast = ""
    
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
                                Text("Informaction del contacto")
                                    .font(.overNormal)
                                    .fontWeight(.w500)
                                    .foregroundColor(.black)
                                    .padding(.top, 30)
                                
                                Spacer()
                            }
                            .padding(.horizontal, 8)
                            
                            CustomTextField(placeholder: "Nombre (s)", text: $name)
                                .frame(height: 50)
                                .padding(.vertical, 4)
                            
                            CustomTextField(placeholder: "Apellido (s)", text: $lastName)
                                .frame(height: 50)
                                .padding(.vertical, 4)
                            
                            Group {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(lineWidth: 1)
                                        .frame(height: 50)
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("País")
                                                .font(.tiny)
                                                .fontWeight(.w500)
                                                .foregroundColor(.gray.opacity(0.9))
                                            
                                            Text("MX 52")
                                                .font(.normal)
                                                .fontWeight(.w500)
                                                .foregroundColor(.gray.opacity(0.9))
                                        }
                                        .padding(.horizontal, 16)
                                        
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        TextField("", text: $mobilePhone)
                                            .frame(height: 50)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 8)
                                            .placeholder("Teléfono Móvil", when: mobilePhone.isEmpty)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            
                            Group {
                                ZStack {
                                    RoundedRectangle(cornerRadius: 8)
                                        .stroke(lineWidth: 1)
                                        .frame(height: 50)
                                        .foregroundColor(.gray.opacity(0.5))
                                    
                                    HStack {
                                        VStack(alignment: .leading) {
                                            Text("País")
                                                .font(.tiny)
                                                .fontWeight(.w500)
                                                .foregroundColor(.gray.opacity(0.9))
                                            
                                            Text("MX 52")
                                                .font(.normal)
                                                .fontWeight(.w500)
                                                .foregroundColor(.gray.opacity(0.9))
                                        }
                                        .padding(.horizontal, 16)
                                        
                                        Rectangle()
                                            .frame(width: 1)
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        TextField("", text: $homePhone)
                                            .frame(height: 50)
                                            .foregroundColor(.black)
                                            .padding(.horizontal, 8)
                                            .placeholder("Teléfono Fijo", when: homePhone.isEmpty)
                                    }
                                }
                            }
                            .padding(.vertical, 4)
                            .padding(.bottom, 20)
                            
                            FiestakiButton(text: "Continuar") {
                                
                                if name.isEmpty {
                                    messageToast = "El nombre no puede estar vacío"
                                    showToast = true
                                    return
                                }
                                
                                if lastName.isEmpty {
                                    messageToast = "El apellido no puede estar vacío"
                                    showToast = true
                                    return
                                }
                                
                                if mobilePhone.isEmpty {
                                    messageToast = "El teléfono móvil no puede estar vacío"
                                    showToast = true
                                    return
                                }
                                
                                let userRequest = UserRequest(role: "client", name: name, last_name: lastName, phone_one: mobilePhone, phone_two: homePhone, email: loginAccount.email, password: loginAccount.password)
                                authViewModel.createNewUserOnServer(userRequest: userRequest, onFinished: {
                                    messageToast = "Cuenta creada con éxito"
                                    showToast = true
                                    authViewModel.signInWithEmailAndPassword(email: loginAccount.email, password: loginAccount.password, validCredentials: { success in
                                        navigation.navigateToRoot()
                                    })
                                })
                            }
                        }
                        .padding()
                    }
                }
                .background(Color.white)
                .cornerRadius(16)
                .shadow(color: .gray.opacity(0.4), radius: 5)
                .padding()
                
                //Spacer()
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .toolbar(.hidden)
    }
}
