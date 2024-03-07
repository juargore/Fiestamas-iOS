//
//  MainTabScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 03/05/23.
//

import SwiftUI

struct MainTabScreen: View {

    @State private var user: FirebaseUserDb? = nil
    @State private var userIcon = "loggedOutIcon"
    @State private var selectedTab = 0
    
    private let numberOfTabs: CGFloat = 3
    private let homeTab = 0
    private let searchTab = 1
    private let miFiestaTab = 2
    private let profileTab = 3
    private let menuTab = 4

    @ObservedObject var mainHomeViewModel: MainHomeViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var mainPartyViewModel: MainPartyViewModel
    @ObservedObject var notificationsViewModel: NotificationsViewModel
    
    init(
        homeViewModel: MainHomeViewModel = MainHomeViewModel(),
        authViewModel: AuthViewModel = AuthViewModel(),
        mainPartyViewModel: MainPartyViewModel = MainPartyViewModel(),
        notificationsViewModel: NotificationsViewModel = NotificationsViewModel()
    ) {
        self.mainHomeViewModel = homeViewModel
        self.authViewModel = authViewModel
        self.mainPartyViewModel = mainPartyViewModel
        self.notificationsViewModel = notificationsViewModel
    }

    var body: some View {

        GeometryReader { proxy in
            ZStack (alignment: .bottomLeading) {
                TabView(selection: $selectedTab) {
                    
                    MainHomeScreen(
                        viewModel: mainHomeViewModel,
                        authViewModel: authViewModel,
                        redirectToMyParty: {
                            selectedTab = miFiestaTab
                        }
                    )
                    .tabItem {
                        if selectedTab == homeTab {
                            Image("homeIcon")
                        } else {
                            Image("homeIcon")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                        }
                    }.tag(0)

                    /*
                    MainSearchScreen(authViewModel: authViewModel)
                    .tabItem {
                        if selectedTab == searchTab {
                            Image("searchIcon")
                        } else {
                            Image("searchIcon")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                        }
                    }.tag(1)
                    */

                    MainPartyScreen(
                        viewModel: mainPartyViewModel,
                        authViewModel: authViewModel,
                        onNavigateHomeClicked: {
                            selectedTab = homeTab
                        },
                        onNavigateLoginClicked: {
                            selectedTab = profileTab
                        }
                    )
                    .tabItem {
                        if selectedTab == miFiestaTab {
                            Image("miFiestaIcn")
                        } else {
                            Image("miFiestaIcn")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                        }
                    }.tag(2)

                    MainProfileScreen(
                        authViewModel: authViewModel,
                        updateIconIfLoggedIn: {
                            userIcon = "loggedInIcon"
                            selectedTab = miFiestaTab
                        },
                        updateIconIfLoggedOut: {
                            userIcon = "loggedOutIcon"
                            selectedTab = miFiestaTab
                        }
                    )
                    .tabItem {
                        if selectedTab == profileTab {
                            Image(userIcon)
                        } else {
                            Image(userIcon)
                                .renderingMode(.template)
                                .foregroundColor(.white)
                        }
                    }.tag(3)

                    /*
                    MainMenuScreen(
                        authViewModel: authViewModel
                    )
                    .tabItem {
                        if selectedTab == menuTab {
                            Image("menuIcon")
                        } else {
                            Image("menuIcon")
                                .renderingMode(.template)
                                .foregroundColor(.white)
                        }
                    }.tag(4)
                    */
                    
                }
                .onAppear {
                    authViewModel.getFirebaseUserDb() { res in
                        self.user = res
                        if user?.role?.getRole() == Role.Unauthenticated {
                            userIcon = "loggedOutIcon"
                        } else {
                            userIcon = "loggedInIcon"
                        }
                    }
                }
                .onChange(of: userIcon) { newIcon in
                    userIcon = newIcon
                }
                
                /// Bottom horizontal line to inform user wich tab is selected
                /*
                Rectangle()
                    .offset(x: proxy.size.width / numberOfTabs  * CGFloat(selectedTab))
                    .frame(width: proxy.size.width / numberOfTabs , height: 2)
                    .animation(.easeInOut(duration: 0.2), value: selectedTab)
                    .padding(.bottom, numberOfTabs)
                */
            }
        }
    }
}
