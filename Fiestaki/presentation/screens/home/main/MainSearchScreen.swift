//
//  SearchScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 03/05/23.
//

import SwiftUI

struct MainSearchScreen: View {
    
    @ObservedObject var authViewModel: AuthViewModel
    @State var user: FirebaseUserDb? = nil
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            VStack {
                mainHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    showNotificationIcon: true
                )
                Spacer()
                //Text("Search")
            }
            .onAppear {
                authViewModel.getFirebaseUserDb() { res in
                    self.user = res
                }
            }
        }
    }
}
