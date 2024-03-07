//
//  AuthNavGraph.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/20/23.
//

import Foundation
import SwiftUI

final class AuthNavGraph: ObservableObject {
    
    public enum Destination: Codable, Hashable {
        case onNavigateToLogin(LoginAccount) // email + password
        case onNavigateToCreatePassword(String) // email
        case onNavigateToCreateUser(LoginAccount) // email + password
        case onNavigateToCreateProvider(LoginAccount) // email + password
    }
    
    @Published var navPath = NavigationPath()
    
    func navigate(to destination: Destination) {
        try navPath.append(destination)
    }
    
    func navigateBack() {
        try navPath.removeLast()
    }
    
    func navigateToRoot() {
        try navPath.removeLast(navPath.count)
    }
}
