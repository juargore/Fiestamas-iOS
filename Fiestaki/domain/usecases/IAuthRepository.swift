//
//  IAuthRepository.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import FirebaseAuth
import Foundation
import Combine

protocol IAuthRepository {
    
    func getFirebaseUser() -> AnyPublisher<FirebaseAuth.User?, Error>
    
    func getFirebaseUserDb(id: String) -> AnyPublisher<FirebaseUserDb?, Error>
    
    func signOutFromFirebaseAuth()
    
    func checkIfEmailExistsInFirebase(email: String) -> AnyPublisher<Bool, Never>
    
    func signInWithEmailAndPassword(email: String, password: String) -> AnyPublisher<LoginResponse, Error>
    
    func registerTokenForPushNotification(token: String, id: String)
    
    func unregisterTokenForPushNotification(token: String, id: String)
    
    func updateTokenForPushNotification(prevToken: String, newToken: String, uid: String)
    
    func createNewUserOnServer(userRequest: UserRequest) -> AnyPublisher<Result<FirebaseUserDb, Error>, Never>
    
    func createNewProviderOnServer(providerRequest: ProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never>
    
    func updateProviderOnServer(providerId: String, providerRequestEdit: ProviderRequestEdit) -> AnyPublisher<Result<Bool, Error>, Never>
    
    func updateClientOnServer(clientId: String, userRequestEdit: UserRequestEdit) -> AnyPublisher<Result<Bool, Error>, Never>
}
