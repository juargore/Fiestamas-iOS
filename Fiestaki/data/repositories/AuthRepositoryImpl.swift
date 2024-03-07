//
//  AuthRepositoryImpl.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation
import Combine

class AuthRepositoryImpl: IAuthRepository {
    
    private var authFirebase = Auth.auth()
    private var firestore = Firestore.firestore()
    private var authApi = AuthApiImplementation()
    private var firebaseUser: FirebaseAuth.User?
        
        init() {
            Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
                self?.firebaseUser = user
            }
        }
    
    func getFirebaseUser() -> AnyPublisher<FirebaseAuth.User?, Error> {
        return Future { promise in
            Auth.auth().addStateDidChangeListener { [weak self] (_, user) in
                self?.firebaseUser = user
                promise(.success(user))
            }
        }.eraseToAnyPublisher()
    }
    
    func getFirebaseUserDb(id: String) -> AnyPublisher<FirebaseUserDb?, Error> {
        let eventRef: DocumentReference = Firestore.firestore().collection(Constants.users).document(id)
        return eventRef.documentListenerFlow(FirebaseUserDb.self)
    }
    
    func signOutFromFirebaseAuth() {
        do {
            try authFirebase.signOut()
            firebaseUser = nil
        } catch {
            debugPrint(error.localizedDescription)
        }
    }
    
    func checkIfEmailExistsInFirebase(email: String) -> AnyPublisher<Bool, Never> {
        let nEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        return Future { promise in
            self.authFirebase.fetchSignInMethods(forEmail: nEmail) { signInMethods, error in
                if let signInMethods = signInMethods {
                    let exists = !signInMethods.isEmpty
                    promise(.success(exists))
                } else {
                    promise(.success(false))
                }
            }
        }.eraseToAnyPublisher()
    }

    func signInWithEmailAndPassword(email: String, password: String) -> AnyPublisher<LoginResponse, Error> {
        let nEmail = email.trimmingCharacters(in: .whitespacesAndNewlines)
        let nPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        return Future { promise in
            self.authFirebase.signIn(withEmail: nEmail, password: nPassword) { result, error in
                        if let error = error {
                            debugPrint("Error Firebase: \(error.localizedDescription)")
                            let response = LoginResponse(success: false, uid: "")
                            promise(.success(response))
                        } else {
                            let response = LoginResponse(success: true, uid: "")
                            promise(.success(response))
                        }
                    }
        }.eraseToAnyPublisher()
    }
    
    func registerTokenForPushNotification(token: String, id: String) {
        let request = SubscribeRequest(device_token: token, uid: id)
        self.authApi.subscribeTokenPushNotifications(subscribeRequest: request)
    }
    
    func unregisterTokenForPushNotification(token: String, id: String) {
        let request = SubscribeRequest(device_token: token, uid: id)
        self.authApi.unsubscribeTokenPushNotifications(subscribeRequest: request)
    }
    
    func updateTokenForPushNotification(prevToken: String, newToken: String, uid: String) {
        let request = UpdateRequest(device_token: newToken, prev_device_token: prevToken, uid: uid)
        self.authApi.updateTokenPushNotifications(updateRequest: request)
    }
    
    func createNewUserOnServer(userRequest: UserRequest) -> AnyPublisher<Result<FirebaseUserDb, Error>, Never> {
        return Future { promise in
            self.authApi.createUserOnServer(userRequest: userRequest) { result in
                switch result {
                case .success(let response):
                    promise(.success(.success(response)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func createNewProviderOnServer(providerRequest: ProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.authApi.createProviderOnServer(providerRequest: providerRequest) { result in
                switch result {
                case .success(let response):
                    promise(.success(.success(response)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateProviderOnServer(providerId: String, providerRequestEdit: ProviderRequestEdit) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.authApi.updateProviderOnServer(
                id_user: providerId,
                providerRequestEdit: providerRequestEdit,
                completion: { result in
                    switch result {
                    case .success(let response):
                        promise(.success(.success(response)))
                    case .failure(let error):
                        promise(.success(.failure(error)))
                    }
                }
            )
        }.eraseToAnyPublisher()
    }
    
    func updateClientOnServer(clientId: String, userRequestEdit: UserRequestEdit) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.authApi.updateClientOnServer(
                id_user: clientId,
                userRequestEdit: userRequestEdit,
                completion: { result in
                    switch result {
                    case .success(let response):
                        promise(.success(.success(response)))
                    case .failure(let error):
                        debugPrint("AQUI: Error: updateClientOnServer: ", error.localizedDescription)
                        promise(.success(.failure(error)))
                    }
                }
            )
        }.eraseToAnyPublisher()
    }
}
