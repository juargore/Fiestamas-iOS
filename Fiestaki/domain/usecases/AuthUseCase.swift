//
//  AuthUseCase.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import FirebaseAuth
import Foundation
import Combine

class AuthUseCase {
    
    private let authRepository = AuthRepositoryImpl()
    private var disposables = Set<AnyCancellable>()
    
    func getFirebaseUser() -> AnyPublisher<FirebaseAuth.User?, Error> {
        return authRepository.getFirebaseUser()
    }
    
    func getFirebaseUserDb(id: String?) -> AnyPublisher<FirebaseUserDb?, Error> {
        if id != nil {
            return authRepository.getFirebaseUserDb(id: id!)
        } else {
            return Future { promise in
                self.authRepository
                    .getFirebaseUser()
                    .sink { _ in } receiveValue: { firebaseUser in
                        if let fUser = firebaseUser {
                            self.getFirebaseUserDbInThread(fUser.uid) { firebaseUserDb in
                                promise(.success(firebaseUserDb))
                            }
                        } else {
                            promise(.success(FirebaseUserDb()))
                        }
                    }.store(in: &self.disposables)
            }.eraseToAnyPublisher()
        }
    }
    
    private func getFirebaseUserDbInThread(_ id: String, _ onFinished: @escaping (FirebaseUserDb?) -> Void) {
        self.authRepository
            .getFirebaseUserDb(id: id)
            .first()
            .sink { _ in } receiveValue: { result in
                onFinished(result)
            }
            .store(in: &disposables)
    }
    
    func signOutFromFirebaseAuth() {
        authRepository.signOutFromFirebaseAuth()
    }
    
    func checkIfEmailExistsInFirebase(email: String) -> AnyPublisher<Bool, Never> {
        return authRepository.checkIfEmailExistsInFirebase(email: email)
    }
    
    func signInWithEmailAndPassword(email: String, password: String) -> AnyPublisher<LoginResponse, Error> {
        return authRepository.signInWithEmailAndPassword(email: email, password: password)
    }
    
    func registerTokenForPushNotification(token: String, id: String) {
        authRepository.registerTokenForPushNotification(token: token, id: id)
    }
    
    func unregisterTokenForPushNotification(token: String, id: String) {
        authRepository.unregisterTokenForPushNotification(token: token, id: id)
    }
    
    func updateTokenForPushNotificationIfNeeded(newToken: String, prevToken: String, id: String) {
        authRepository.updateTokenForPushNotification(prevToken: prevToken, newToken: newToken, uid: id)
    }
    
    func createNewUserOnServer(userRequest: UserRequest) -> AnyPublisher<Result<FirebaseUserDb, Error>, Never> {
        return authRepository.createNewUserOnServer(userRequest: userRequest)
    }
    
    func createNewProviderOnServer(providerRequest: ProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never> {
        return authRepository.createNewProviderOnServer(providerRequest: providerRequest)
    }
    
    func updateProviderOnServer(providerId: String, providerRequestEdit: ProviderRequestEdit) -> AnyPublisher<Result<Bool, Error>, Never> {
        return authRepository.updateProviderOnServer(providerId: providerId, providerRequestEdit: providerRequestEdit)
    }
    
    func updateClientOnServer(clientId: String, userRequest: UserRequestEdit) -> AnyPublisher<Result<Bool, Error>, Never> {
        return authRepository.updateClientOnServer(clientId: clientId, userRequestEdit: userRequest)
    }
}
