//
//  ProviderInfoScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 22/05/23.
//

import SwiftUI
import CoreLocation

struct CreateProviderScreen: View {
    
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: AuthNavGraph
    
    var loginAccount: LoginAccount
    
    @State private var showToast = false
    @State private var messageToast = ""
    @State private var isShowingAutocomplete = false
    
    @State private var businessName = ""
    @State private var firstName = ""
    @State private var lastName = ""
    @State private var mobilePhone = ""
    @State private var homePhone = ""
    @State private var rfc = ""
    
    @State private var cAddress = ""
    @State private var city = ""
    @State private var state = ""
    @State private var postalCode = ""
    @State private var country = ""
    @State private var latitude = ""
    @State private var longitude = ""

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
                                Text("Nombre del negocio")
                                    .font(.overNormal)
                                    .fontWeight(.w500)
                                    .foregroundColor(.black)
                                    .padding(.top, 20)

                                Spacer()
                            }
                            .padding(.horizontal, 8)

                            CustomTextField(placeholder: "Nombre", text: $businessName)
                                .frame(height: 50)
                                .padding(.vertical, 4)

                            HStack {
                                Text("Informaction del contacto")
                                    .font(.overNormal)
                                    .fontWeight(.w500)
                                    .foregroundColor(.black)

                                Spacer()
                            }

                            Group {
                                Group {
                                    CustomTextField(placeholder: "Nombre (s)", text: $firstName)
                                        .frame(height: 50)
                                        .padding(.vertical, 4)
                                }

                                Group {
                                    CustomTextField(placeholder: "Apellido (s)", text: $lastName)
                                        .frame(height: 50)
                                        .padding(.vertical, 4)
                                }

                                Group {
                                    CustomTextField(placeholder: "Domicilio (escribir aquí)", text: $cAddress)
                                        .frame(height: 50)
                                        .padding(.vertical, 4)
                                        .foregroundColor(.ashGray)
                                        .onTapGesture {
                                            isShowingAutocomplete.toggle()
                                        }
                                }

                                Group {
                                    CustomTextField(placeholder: "Ciudad", text: $city)
                                        .frame(height: 50)
                                        .padding(.vertical, 4)
                                        .foregroundColor(.ashGray)
                                        .disabled(true)
                                }

                                Group {
                                    CustomTextField(placeholder: "Estado", text: $state)
                                        .frame(height: 50)
                                        .padding(.vertical, 4)
                                        .foregroundColor(.ashGray)
                                        .disabled(true)
                                }

                                Group {
                                    CustomTextField(placeholder: "Confirmar Código postal", text: $postalCode)
                                        .frame(height: 50)
                                        .padding(.vertical, 4)
                                        .foregroundColor(.ashGray)
                                        .disabled(true)
                                }

                                Group {
                                    CustomTextField(placeholder: "Confirmar País", text: $country)
                                        .frame(height: 50)
                                        .padding(.vertical, 4)
                                        .foregroundColor(.ashGray)
                                        .disabled(true)
                                }
                            }

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
                                            .frame(height: 50)
                                            .foregroundColor(.gray.opacity(0.5))
                                        
                                        TextField("", text: $mobilePhone)
                                            .fontWeight(.w500)
                                            .font(.system(size: 18))
                                            .frame(height: 50)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .foregroundColor(.black)
                                            .placeholder("Teléfono Móvil", when: mobilePhone.isEmpty)
                                    }
                                }
                            }
                                
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
                                            .frame(height: 50)
                                            .foregroundColor(.gray.opacity(0.5))

                                        TextField("", text: $homePhone)
                                            .fontWeight(.w500)
                                            .font(.system(size: 18))
                                            .frame(height: 50)
                                            .padding(.vertical, 4)
                                            .padding(.horizontal, 8)
                                            .foregroundColor(.black)
                                            .placeholder("Teléfono Fijo", when: homePhone.isEmpty)
                                    }
                                }
                            } 
                                
                            Group {
                                CustomTextField(placeholder: "RFC", text: $rfc)
                                    .frame(height: 50)
                                    .padding(.vertical, 4)
                            }

                            Group {
                                FiestakiButton(text: "Continuar") {
                                    if businessName.isEmpty {
                                        messageToast = "El nombre del negocio no puede estar vacío"
                                        showToast = true
                                        return
                                    }
                                    
                                    if firstName.isEmpty {
                                        messageToast = "El nombre no puede estar vacío"
                                        showToast = true
                                        return
                                    }
                                    
                                    if lastName.isEmpty {
                                        messageToast = "El apellido no puede estar vacío"
                                        showToast = true
                                        return
                                    }
                                    
                                    if cAddress.isEmpty {
                                        messageToast = "La dirección no puede estar vacía"
                                        showToast = true
                                        return
                                    }
                                    
                                    if mobilePhone.isEmpty {
                                        messageToast = "El teléfono móvil no puede estar vacío"
                                        showToast = true
                                        return
                                    }
                                    
                                    let providerRequest = ProviderRequest(role: "provider", name: firstName, email: loginAccount.email, phone_one: mobilePhone, phone_two: homePhone, business_name: businessName, state: state, city: city, cp: postalCode, rfc: rfc, country: "Mexico", password: loginAccount.password, last_name: lastName, lat: String(latitude), lng: String(longitude)
                                    )
                                    authViewModel.createNewProviderOnServer(providerRequest: providerRequest) {
                                        messageToast = "Cuenta creada con éxito"
                                        showToast = true
                                        authViewModel.signInWithEmailAndPassword(email: loginAccount.email, password: loginAccount.password, validCredentials: { success in
                                            navigation.navigateToRoot()
                                        })
                                    }
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
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .toolbar(.hidden)
        .sheet(isPresented: $isShowingAutocomplete) {
            AddressAutoCompleteScreen(
                searchType: AddressSearchType.address,
                onAddressSelected: { address in
                    if address != nil {
                        cAddress = address?.line1 ?? ""
                        city = address?.city ?? ""
                        state = address?.state ?? ""
                        postalCode = address?.zipcode ?? ""
                        country = address?.country ?? ""
                        latitude = address?.location?.lat ?? ""
                        longitude = address?.location?.lng ?? ""
                    }
                    isShowingAutocomplete = false
                }
            )
            .presentationDetents([.medium, .medium])
            .presentationDragIndicator(.visible)
        }
    }
}
