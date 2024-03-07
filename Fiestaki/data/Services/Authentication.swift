//
//  Authentication.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 15/05/23.
//

import FirebaseAuth

protocol AuthenticationProtocol {
    func signUpUser(email: String, password: String) async throws -> AuthDataResult
    func signInUser(email: String, password: String) async throws -> UserLogin
    func isUserLoggedIn() async -> Bool
    func checkIfEmailExists(email: String) async throws -> Bool
    func signOutUser()
}

final class Authentication: AuthenticationProtocol {

    private let authentication: Auth

    init(authentication: Auth = Auth.auth()) {
        self.authentication = authentication
    }

    func signUpUser(email: String, password: String) async throws -> AuthDataResult {

        do {
            let authResult = try await authentication.createUser(withEmail: email, password: password)
            let user = authResult.user
            try await user.sendEmailVerification()
            // User signed up successfully
            return authResult

        } catch let error {
            // Handle the sign-up error
            debugPrint("Sign up error: ", error)
            throw error
        }
    }

    func signInUser(email: String, password: String) async throws -> UserLogin {
        do {
            let authResult = try await authentication.signIn(withEmail: email, password: password)

            let user = authResult.user

            return UserLogin(id: user.uid,
                             email: user.email ?? "",
                             displayName: user.displayName ?? "")

        } catch let error {
            // Handle the sign-up error
            debugPrint("Sign in error: ", error)
            throw error
        }
    }

    func isUserLoggedIn() async -> Bool {
        do {
            if authentication.currentUser != nil {
                return true
            }
            return false
        }
    }

    func checkIfEmailExists(email: String) async throws -> Bool {

        do {
            let signInMethods = try await authentication.fetchSignInMethods(forEmail: email)
            // User signed up successfully
            debugPrint("authResult: ", signInMethods)

            return !signInMethods.isEmpty

        } catch let error {
            // Handle the sign-up error
            debugPrint("Sign up error: ", error)
            throw error
        }
    }

    func signOutUser(){
        try? authentication.signOut()
    }
}
