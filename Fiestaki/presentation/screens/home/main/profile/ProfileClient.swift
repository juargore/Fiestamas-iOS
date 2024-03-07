//
//  ProfileClient.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 12/29/23.
//

import Foundation
import SwiftUI

struct ProfileClient: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    
    var firebaseUserDb: FirebaseUserDb
    var onSignedOut: () -> Void
    var showProgress: (Bool) -> Void
    
    @State private var image: Image? = nil
    @State private var imageWidth: CGFloat = 0.0
    @State private var imageHeight: CGFloat = 0.0
    @State private var shouldPresentImagePicker = false
    @State private var shouldPresentActionSheet = false
    @State private var shouldPresentCamera = false
    @State private var showToast = false
    @State private var messageToast = ""
    
    @State private var name: String
    @State private var email: String
    @State private var lastName: String
    @State private var mobilePhone: String
    @State private var homePhone: String
    
    init(
        authViewModel: AuthViewModel,
        firebaseUserDb: FirebaseUserDb,
        onSignedOut: @escaping () -> Void,
        showProgress: @escaping (Bool) -> Void
    ) {
        self.authViewModel = authViewModel
        self.firebaseUserDb = firebaseUserDb
        self.onSignedOut = onSignedOut
        self.showProgress = showProgress
        
        self.name = firebaseUserDb.name ?? ""
        self.email = firebaseUserDb.email ?? ""
        self.lastName = firebaseUserDb.last_name ?? ""
        self.mobilePhone = firebaseUserDb.phone_one ?? ""
        self.homePhone = firebaseUserDb.phone_two ?? ""
    }
    
    var body: some View {
        VStack {
            // start profile photo and 'change photo' section
            HStack {
                ProfilePhoto(firebaseUserDb: firebaseUserDb, image: image)
                Spacer(minLength: 20)
                VStack {
                    HStack {
                        Text("\(name) \(lastName)")
                            .font(.headline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    HStack {
                        Text(email)
                            .font(.subheadline)
                            .foregroundColor(.black)
                        Spacer()
                    }
                    HStack {
                        HStack {
                            Text("Cambiar foto")
                                .font(.footnote)
                                .foregroundColor(.hotPink)
                                .padding(.horizontal, 16)
                                .padding(.vertical, 6)
                        }
                        .background(Color.white)
                        .clipShape(RoundedRectangle(cornerRadius: 15))
                        .overlay(RoundedRectangle(cornerRadius: 15).stroke(Color.hotPink, lineWidth: 0.8))
                        .onTapGesture {
                            self.shouldPresentActionSheet = true
                        }
                        
                        Spacer()
                    }
                }
            }
            // end profile photo and 'change photo' section
            
            Spacer(minLength: 30)
            
            HStack {
                VStack {
                    Spacer()
                    Text("Editar Perfil")
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.black)
                }
                Spacer()
                HStack {
                    Text("Cerrar sesión")
                        .font(.footnote)
                        .foregroundColor(.white)
                        .padding(.horizontal, 18)
                        .padding(.vertical, 8)
                }
                .background(Color(UIColor(hex: "#6200EE")))
                .clipShape(RoundedRectangle(cornerRadius: 6))
                .onTapGesture { onSignedOut() }
            }
            
            Spacer(minLength: 20)
            
            Group {
                Group {
                    CustomTextField(placeholder: "Nombre (s)", text: $name)
                        .frame(height: 50)
                        .padding(.vertical, 4)
                }
                
                Group {
                    CustomTextField(placeholder: "Apellido (s)", text: $lastName)
                        .frame(height: 50)
                        .padding(.vertical, 4)
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
                            .foregroundColor(.gray.opacity(0.5))
                            .padding(.vertical, 4)

                        TextField("", text: $mobilePhone)
                            .fontWeight(.w500)
                            .font(.system(size: 18))
                            .frame(height: 50)
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                            .placeholder("Teléfono Móvil", when: mobilePhone.isEmpty)
                    }
                }
                
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
                            .padding(.vertical, 4)

                        TextField("", text: $homePhone)
                            .fontWeight(.w500)
                            .font(.system(size: 18))
                            .frame(height: 50)
                            .foregroundColor(.black)
                            .padding(.vertical, 4)
                            .placeholder("Teléfono fijo", when: homePhone.isEmpty)
                    }
                }
            }
            
            Spacer(minLength: 25)
            
            Group {
                FiestakiButton(text: "Actualizar Perfil") {
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
                    
                    showProgress(true)
                    
                    let userRequestEdit = UserRequestEdit(
                        name: name,
                        email: email,
                        phone_one: mobilePhone,
                        phone_two: homePhone,
                        last_name: lastName,
                        photo: firebaseUserDb.photo ?? ""
                    )
                    
                    authViewModel.updateClientOnServer(
                        photo: image,
                        width: imageWidth,
                        height: imageHeight,
                        clientId: firebaseUserDb.id!,
                        userRequestEdit: userRequestEdit,
                        onFinished: {
                            showProgress(false)
                            messageToast = "Perfil actualizado con éxito!"
                            showToast = true
                        }
                    )
                }
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .sheet(isPresented: $shouldPresentImagePicker) {
                SUImagePickerView(
                    sourceType: self.shouldPresentCamera ? .camera : .photoLibrary,
                    image: self.$image,
                    isPresented: self.$shouldPresentImagePicker,
                    imageWidth: self.$imageWidth,
                    imageHeight: self.$imageHeight
                )}
        .actionSheet(isPresented: $shouldPresentActionSheet) { () -> ActionSheet in
            ActionSheet(
                title: Text("Envíar imagen vía"),
                buttons: [ActionSheet.Button.default(Text("Cámara fotográfica"),
                action: {
                    self.shouldPresentImagePicker = true
                    self.shouldPresentCamera = true
                }), ActionSheet.Button.default(Text("Galería de imágenes"), action: {
                    self.shouldPresentImagePicker = true
                    self.shouldPresentCamera = false
                }), ActionSheet.Button.cancel()]
            )
        }
    }
}
