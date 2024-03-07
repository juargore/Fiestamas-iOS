//
//  ProfileScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 03/05/23.
//

import SwiftUI
import FirebaseAuth

struct MainProfileScreen: View {

    @ObservedObject var authViewModel: AuthViewModel
    
    var updateIconIfLoggedIn: () -> Void
    var updateIconIfLoggedOut: () -> Void
    
    @State private var user: FirebaseUserDb? = nil
    
    var body: some View {
        ZStack {
            if user?.role?.getRole() != Role.Unauthenticated {
                if user != nil {
                    UserProfile(
                        authViewModel: authViewModel,
                        user: user!,
                        role: user?.role?.getRole() ?? Role.Client,
                        onSignedOut: {
                            updateIconIfLoggedOut()
                        }
                    )
                }
                
            } else {
                StartEmailScreenForTab(
                    authViewModel: authViewModel,
                    informThatUserIsAlreadyLoggedIn: {
                        updateIconIfLoggedIn()
                    }
                )
            }
        }
        .onAppear {
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
            }
        }
    }
}

struct UserProfile: View {
    
    var authViewModel: AuthViewModel
    var user: FirebaseUserDb
    var role: Role
    var onSignedOut: () -> Void
    
    @State private var showYesNoDialogToExitApp = false
    @State private var showProgressDialog = false
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            VStack {
                mainHeader(
                    userIsLoggedIn: true,
                    username: user.name ?? "",
                    showNotificationIcon: false
                )
                
                ZStack {
                    ScrollView(.vertical) {
                        VStack {
                            if role == Role.Provider {
                                ProfileProvider(
                                    authViewModel: authViewModel,
                                    firebaseUserDb: user,
                                    onSignedOut: {
                                        showYesNoDialogToExitApp = true
                                    },
                                    showProgress: { show in
                                        self.showProgressDialog = show
                                    }
                                )
                            } else {
                                ProfileClient(
                                    authViewModel: authViewModel,
                                    firebaseUserDb: user,
                                    onSignedOut: {
                                        showYesNoDialogToExitApp = true
                                    },
                                    showProgress: { show in
                                        self.showProgressDialog = show
                                    }
                                )
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
        .popUpDialog(isShowing: $showProgressDialog, dialogContent: {
            ProgressDialog(isVisible: showProgressDialog, message: "Actualizando Perfil...")
        })
        .popUpDialog(isShowing: $showYesNoDialogToExitApp, dialogContent: {
            YesNoDialog(
                message: "¿Confirma que desea cerrar sesión?",
                icon: "ic_question_circled",
                onDismiss: {
                    showYesNoDialogToExitApp = false
                },
                onOk: {
                    showYesNoDialogToExitApp = false
                    authViewModel.signOutFromAccount(uid: user.id!)
                    onSignedOut()
                }
            )
        })
    }
}


struct ProfilePhoto: View {
    
    var firebaseUserDb: FirebaseUserDb
    var image: Image?
    
    let w: CGFloat = 100
    let h: CGFloat = 100
    let lw: CGFloat = 3
    
    var body: some View {
        if image != nil {
            image!
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(width: w, height: h)
                .clipShape(Circle())
                .overlay(Circle().stroke(Color.ashGray, lineWidth: lw))
        } else {
            let photo = firebaseUserDb.photo
            if photo == nil || photo?.isEmpty == true {
                Image("ic_user")
                    .resizable()
                    .frame(width: w, height: h)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.ashGray, lineWidth: lw))
            } else {
                RemoteImage(urlString: photo!)
                    .frame(width: w, height: h)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.ashGray, lineWidth: lw))
            }
        }
    }
}
