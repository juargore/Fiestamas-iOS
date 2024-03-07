//
//  ServicesView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 09/06/23.
//

import SwiftUI

struct SubServicesScreen: View {
    
    @ObservedObject var viewModel = SubServicesViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: ServicesSelectionNavGraph
    
    var screenInfo: ScreenInfo
    @State var user: FirebaseUserDb? = nil
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()

            VStack {
                servicesHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    title: screenInfo.event?.name ?? "",
                    subTitle: viewModel.getLikedStrings(screenInfo: screenInfo),
                    smallSubtitle: true
                ) {
                    navigation.navigateBack()
                }
                
                ScrollView(.vertical) {
                    VStack {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.subServices, id: \.self) { subService in
                                CardSubService(title: subService.name, imageUrl: subService.icon) {
                                    if screenInfo.role == Role.Provider {
                                        navigation.navigate(to: .onNavigateAddServiceProvider1(
                                            viewModel.getNewScreenInfo(screenInfo: screenInfo, subService: subService), nil))
                                    } else {
                                        navigation.navigate(to: .onNavigateServices(
                                            viewModel.getNewScreenInfo(screenInfo: screenInfo, subService: subService)
                                        ))
                                    }
                                }
                                .frame(width: UIScreen.width / 3 - 15)
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                }
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .onAppear {
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
            }
            viewModel.getSubServicesByServiceTypeId(serviceTypeId: screenInfo.serviceType?.id ?? "")
        }
    }
}
