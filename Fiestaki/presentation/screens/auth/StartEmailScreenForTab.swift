//
//  LoginScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 15/05/23.
//

import SwiftUI

struct StartEmailScreenForTab: View {

    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var navigation = AuthNavGraph()
    
    var informThatUserIsAlreadyLoggedIn: () -> Void
    
    @State var email: String = ""
    @State private var showToast = false
    @State private var messageToast = ""
    
    @State private var selectedAccount: LoginAccount? = nil
    @State private var showAutoCompleteTextField = false

    var body: some View {
        NavigationStack(path: $navigation.navPath) {
            ZStack {
                backgroundLinearGradient()
                VStack {
                    mainHeader(
                        userIsLoggedIn: false,
                        username: "",
                        showNotificationIcon: false
                    )

                    ZStack {
                        VStack {
                            Text("Inicia sesión")
                                .font(.big)
                                .fontWeight(.w700)
                                .foregroundColor(.hotPink)
                                .padding(.top, 20)
                            
                            CustomTextField(placeholder: "E-mail", text: $email)
                                .padding(.top, 10)
                                .padding(.bottom, 5)
                                .onChange(of: email) { nQuery in
                                    if nQuery.count >= 3 {
                                        authViewModel.getStoredAccountsFromInternalDb(query: email)
                                    }
                                    showAutoCompleteTextField = email.count >= 3
                                }
                            
                            if showAutoCompleteTextField {
                                LazyVStack {
                                    ForEach(authViewModel.accountsList, id: \.self) { account in
                                        HStack {
                                            Text(account.email)
                                                .font(.subheadline)
                                                .foregroundColor(.black)
                                                .onTapGesture {
                                                    email = account.email
                                                    selectedAccount = account
                                                    showAutoCompleteTextField = false
                                                }
                                            Spacer()
                                        }
                                        .padding(.vertical, 3)
                                    }
                                }
                                .padding(.bottom, 15)
                            }

                            FiestakiButton(text: "Continuar") {
                                if isValidEmail(email) {
                                    authViewModel.checkIfEmailExistsInFirebase(email: email, existsEmailInFirebase: { exists in
                                        if exists {
                                            navigation.navigate(to: .onNavigateToLogin(
                                                LoginAccount(email: email, password: selectedAccount?.password ?? ""))
                                            )
                                        } else {
                                            navigation.navigate(to: .onNavigateToCreatePassword(email))
                                        }
                                    })
                                } else {
                                    messageToast = "El email es inválido"
                                    showToast = true
                                }
                            }

                            separator
                                .padding(.horizontal, 40)
                                .padding(.top, 16)

                            termsAndPrivacy
                                .padding(.horizontal, 16)
                                .padding(.top, 16)

                            footer
                                .padding(.horizontal, 50)
                                .padding(.vertical, 20)
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
            .navigationDestination(for: AuthNavGraph.Destination.self) { destination in
                switch destination {
                case .onNavigateToLogin(let account):
                    LogInScreen(loginAccount: account)
                        .environmentObject(navigation)
                case .onNavigateToCreatePassword(let email):
                    CreatePasswordScreen(email: email)
                        .environmentObject(navigation)
                case .onNavigateToCreateUser(let account):
                    CreateUserScreen(loginAccount: account)
                        .environmentObject(navigation)
                case .onNavigateToCreateProvider(let account):
                    CreateProviderScreen(loginAccount: account)
                        .environmentObject(navigation)
                }
            }
            .environmentObject(navigation)
            .onAppear {
                authViewModel.getFirebaseUserDb() { user in
                    if user?.role?.getRole() != Role.Unauthenticated {
                        informThatUserIsAlreadyLoggedIn()
                    }
                }
                authViewModel.getAllStoredAccountsFromAppStorage()
            }
        }
    }

    var separator: some View {
        HStack(spacing: 16){
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.black)

            Text("O")
                .font(.overNormal)
                .fontWeight(.w600)
                .foregroundColor(.black)

            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.black)
        }
    }

    var termsAndPrivacy: some View {
        VStack(spacing: 20) {
            HStack {
                Group {
                    Text("Al iniciar sesión o al crear una cuenta, aceptas nuestros ")
                        .font(.tiny)
                        .foregroundColor(.black)
                        .fontWeight(.w500) +
                    Text("Términos y condiciones")
                        .font(.tiny)
                        .foregroundColor(Color.hotPink)
                        .fontWeight(.w500)
                        .foregroundColor(.hotPink) +
                    Text(" y la ")
                        .font(.tiny)
                        .foregroundColor(.black)
                        .fontWeight(.w500) +
                    Text("Política de privacidad")
                        .font(.tiny)
                        .foregroundColor(Color.hotPink)
                        .fontWeight(.w500)
                        .foregroundColor(.hotPink)
                }
                .padding(.horizontal, 10)
                .multilineTextAlignment(.center)
                .onTapGesture {
                    openURLInBrowser("https://fiestamas.com/privacy-policy")
                }
            }
            
            Rectangle()
                .frame(height: 0.5)
                .foregroundColor(.black)
                .padding(.horizontal, 22)
        }
    }

    var footer: some View {
        Text("Todos los derechos reservados. Copyright (2024) - FIESTAKI.com®")
            .font(.tiny)
            .fontWeight(.w500)
            .multilineTextAlignment(.center)
            .foregroundColor(Color.gray)
    }
}
