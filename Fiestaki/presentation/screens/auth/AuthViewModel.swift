//
//  AuthViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/9/23.
//

import Foundation
import SwiftUI
import Combine
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseAnalytics
import GoogleSignIn
import GooglePlaces
import CoreLocation
import FirebaseMessaging

final class AuthViewModel: ObservableObject {
    
    private let authUseCase = AuthUseCase()
    private let serviceUseCase = ServiceUseCase()
    private var disposables = Set<AnyCancellable>()
    
    @Published var appStorageManager = AppStorageManager()
    @Published var allStoredAccounts: [LoginAccount] = []
    @Published var accountsList: [LoginAccount] = []
    
    func getAllStoredAccountsFromAppStorage() {
        allStoredAccounts = self.appStorageManager.getStoredAccountsAsList()
    }
    
    func getStoredAccountsFromInternalDb(query: String) {
        if query.count > 3 {
            let filteredList = allStoredAccounts.filter { account in
                account.email.localizedCaseInsensitiveContains(query)
            }
            accountsList = filteredList
        } else {
            accountsList = []
        }
    }
    
    func getFirebaseUser(onResult: @escaping (FirebaseAuth.User?) -> Void) {
        authUseCase
            .getFirebaseUser()
            .sink { _ in } receiveValue: { firebaseUser in
                onResult(firebaseUser)
            }.store(in: &disposables)
    }
    
    func getFirebaseUserDb(id: String? = nil, onResult: @escaping (FirebaseUserDb?) -> Void) {
        authUseCase
            .getFirebaseUserDb(id: id)
            .sink { _ in } receiveValue: { firebaseUserDb in
                onResult(firebaseUserDb)
            }.store(in: &disposables)
    }
    
    func getFirebaseProviderDb(providerId: String, onResult: @escaping (FirebaseUserDb?) -> Void) {
        authUseCase
            .getFirebaseUserDb(id: providerId)
            .sink { _ in } receiveValue: { provider in
                onResult(provider)
            }.store(in: &disposables)
    }
    
    func getUserRole(_ user: FirebaseUserDb?) -> Role {
        return (user?.role ?? "").getRole()
    }
    
    func signOutFromAccount(uid: String?) {
        if uid != nil {
            let currentToken = self.appStorageManager.getValue(model: String.self, for: StorageKeys.lastTokenPush) ?? ""
            self.unregisterTokenForPushNotification(token: currentToken, id: uid!)
        }
        authUseCase.signOutFromFirebaseAuth()
    }
    
    func checkIfEmailExistsInFirebase(email: String, existsEmailInFirebase: @escaping (Bool) -> Void) {
        authUseCase
            .checkIfEmailExistsInFirebase(email: email)
            .sink { _ in } receiveValue: { exists in
                existsEmailInFirebase(exists)
            }.store(in: &disposables)
    }
    
    func storeAccountIntoAppStorage(data: LoginAccount) {
        self.appStorageManager.saveLoginAccountIfNeeded(data: data)
    }
    
    func signInWithEmailAndPassword(email: String, password: String, validCredentials: @escaping (Bool) -> Void) {
        authUseCase
            .signInWithEmailAndPassword(email: email, password: password)
            .sink { _ in } receiveValue: { response in
                validCredentials(response.success)
                
                if (response.success) {
                    if let fcm = Messaging.messaging().fcmToken {
                        self.registerTokenForPushNotification(token: fcm, id: response.uid)
                    }
                }
            }.store(in: &disposables)
    }
    
    func updateTokenPushNotificationIfPossible(newToken: String) {
        getFirebaseUser() { user in
            if user != nil {
                let prevToken = self.appStorageManager.getValue(model: String.self, for: StorageKeys.lastTokenPush) ?? ""
                if prevToken != newToken {
                    self.updateTokenForPushNotification(newToken: newToken, prevToken: prevToken, id: user!.uid)
                }
            }
        }
    }
    
    func registerTokenForPushNotification(token: String, id: String) {
        debugPrint("Token will be added (\(id)): ", token)
        authUseCase.registerTokenForPushNotification(token: token, id: id)
        self.appStorageManager.storeValue(token, for: StorageKeys.lastTokenPush)
    }
    
    func unregisterTokenForPushNotification(token: String, id: String) {
        debugPrint("Token will be deleted (\(id)): ", token)
        authUseCase.unregisterTokenForPushNotification(token: token, id: id)
        self.appStorageManager.storeValue("", for: StorageKeys.lastTokenPush)
    }
    
    func updateTokenForPushNotification(newToken: String, prevToken: String, id: String) {
        debugPrint("Token will be updated (\(id)): ", newToken)
        authUseCase.updateTokenForPushNotificationIfNeeded(newToken: newToken, prevToken: prevToken, id: id)
        self.appStorageManager.storeValue(newToken, for: StorageKeys.lastTokenPush)
    }
    
    func createNewUserOnServer(userRequest: UserRequest, onFinished: @escaping () -> Void) {
        authUseCase
            .createNewUserOnServer(userRequest: userRequest)
            .sink { _ in } receiveValue: { response in
                onFinished()
            }.store(in: &disposables)
    }
    
    func createNewProviderOnServer(providerRequest: ProviderRequest, onFinished: @escaping () -> Void) {
        authUseCase
            .createNewProviderOnServer(providerRequest: providerRequest)
            .sink { _ in } receiveValue: { response in
                onFinished()
            }.store(in: &disposables)
    }
    
    func updateProviderOnServer(
        photo: Image?,
        width: CGFloat,
        height: CGFloat,
        providerId: String,
        providerRequestEdit: ProviderRequestEdit,
        onFinished: @escaping () -> Void
    ) {
        // first, upload image on server
        if photo != nil {
            if let uri = getUriFromImage(photo!, width: width, height: height) {
                let imageAbsolutePath = uri.absoluteString
                var imageName = ""
                if let index = imageAbsolutePath.lastIndex(of: "/") {
                    imageName = String(imageAbsolutePath.suffix(from: index).dropFirst())
                }
                let images = [UriFile(uri: uri, fileName: imageName)]
                serviceUseCase
                    .uploadMediaFiles(images: images, videos: nil)
                    .sink { _ in } receiveValue: { response in
                        
                        // after we get image link -> update
                        let linkImage = !response.firstList.isEmpty ? response.firstList.first : ""
                        let request = ProviderRequestEdit(
                            name: providerRequestEdit.name,
                            last_name: providerRequestEdit.last_name,
                            email: providerRequestEdit.email,
                            phone_one: providerRequestEdit.phone_one,
                            phone_two: providerRequestEdit.phone_two,
                            photo: linkImage ?? "",
                            rfc: providerRequestEdit.rfc,
                            address: providerRequestEdit.address,
                            state: providerRequestEdit.state,
                            city: providerRequestEdit.city,
                            cp: providerRequestEdit.cp,
                            country: providerRequestEdit.country,
                            lat: providerRequestEdit.lat,
                            lng: providerRequestEdit.lng
                        )
                        
                        self.authUseCase
                            .updateProviderOnServer(providerId: providerId, providerRequestEdit: request)
                            .sink { result in
                                switch result {
                                    case .finished: onFinished()
                                    case .failure(_): onFinished()
                                }
                            } receiveValue: { _ in }.store(in: &self.disposables)
                    }.store(in: &self.disposables)
            } else {
                debugPrint("AQUI: No se pudo convertir la imagen a URI")
                onFinished()
            }
        } else {
            self.authUseCase
                .updateProviderOnServer(providerId: providerId, providerRequestEdit: providerRequestEdit)
                .sink { result in
                    switch result {
                        case .finished: onFinished()
                        case .failure(_): onFinished()
                    }
                } receiveValue: { _ in }.store(in: &self.disposables)
        }
    }
    
    func updateClientOnServer(
        photo: Image?,
        width: CGFloat,
        height: CGFloat,
        clientId: String,
        userRequestEdit: UserRequestEdit,
        onFinished: @escaping () -> Void
    ) {
        // first, upload image on server
        if photo != nil {
            if let uri = getUriFromImage(photo!, width: width, height: height) {
                let imageAbsolutePath = uri.absoluteString
                var imageName = ""
                if let index = imageAbsolutePath.lastIndex(of: "/") {
                    imageName = String(imageAbsolutePath.suffix(from: index).dropFirst())
                }
                let images = [UriFile(uri: uri, fileName: imageName)]
                serviceUseCase
                    .uploadMediaFiles(images: images, videos: nil)
                    .sink { _ in } receiveValue: { response in
                        
                        // after we get image link -> update
                        let linkImage = !response.firstList.isEmpty ? response.firstList.first : ""
                        let request = UserRequestEdit(
                            name: userRequestEdit.name,
                            email: userRequestEdit.email,
                            phone_one: userRequestEdit.phone_one,
                            phone_two: userRequestEdit.phone_two,
                            last_name: userRequestEdit.last_name,
                            photo: linkImage ?? ""
                        )
                        self.authUseCase
                            .updateClientOnServer(clientId: clientId, userRequest: request)
                            .sink { result in
                                switch result {
                                    case .finished: onFinished()
                                    case .failure(_): onFinished()
                                }
                            } receiveValue: { _ in }.store(in: &self.disposables)
                    }.store(in: &self.disposables)
            } else {
                debugPrint("AQUI: No se pudo convertir la imagen a URI")
                onFinished()
            }
        } else {
            self.authUseCase
                .updateClientOnServer(clientId: clientId, userRequest: userRequestEdit)
                .sink { result in
                    switch result {
                        case .finished: onFinished()
                        case .failure(_): onFinished()
                    }
                } receiveValue: { _ in }.store(in: &self.disposables)
        }
    }
}
