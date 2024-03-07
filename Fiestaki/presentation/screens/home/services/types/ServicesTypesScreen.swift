//
//  SubCategoryView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 05/06/23.
//

import SwiftUI

struct ServicesTypesScreen: View {
    
    @ObservedObject var viewModel = ServicesTypesViewModel()
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
                    subTitle: screenInfo.serviceCategory?.name ?? ""
                ) {
                    navigation.navigateBack()
                }
                
                ScrollView(.vertical) {
                    VStack {
                        LazyVGrid(columns: columns, spacing: 10) {
                            ForEach(viewModel.servicesByCategory, id: \.self) { serviceType in
                                CardServiceType(title: serviceType.name , imageUrl: serviceType.icon) {
                                    viewModel.getSubServicesCountByServiceTypeId(
                                        serviceTypeId: serviceType.id!
                                    ) { subServices in
                                        if subServices == 0 {
                                            if screenInfo.role == Role.Provider {
                                                // there is no subServices for this serviceType -> go to add service provider
                                                navigation.navigate(to: .onNavigateAddServiceProvider1(
                                                    viewModel.getNewScreenInfo(
                                                        screenInfo: screenInfo,
                                                        serviceType: serviceType,
                                                        subServiceType: nil
                                                    ), nil))
                                            } else {
                                                // there is no subServices for this serviceType -> go to Services screen
                                                navigation.navigate(to: .onNavigateServices(
                                                    viewModel.getNewScreenInfo(
                                                        screenInfo: screenInfo,
                                                        serviceType: serviceType,
                                                        subServiceType: nil
                                                    )
                                                ))
                                            }
                                        } else {
                                            // there is at least one subServices -> go to SubServices screen
                                            navigation.navigate(to: .onNavigateSubServices(
                                                viewModel.getNewScreenInfo(
                                                    screenInfo: screenInfo,
                                                    serviceType: serviceType,
                                                    subServiceType: nil
                                                )
                                            ))
                                        }
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
            if screenInfo.role != Role.Unauthenticated {
                authViewModel.getFirebaseUserDb() { res in
                    self.user = res
                    if screenInfo.role == Role.Client && screenInfo.prevScreen == Screen.Home {
                        viewModel.createEventByClient(
                            clientId: self.user?.id ?? "",
                            eventId: screenInfo.event?.id ?? "",
                            questions: screenInfo.questions!,
                            onEventCreated: { response  in
                                // do nothing...
                            }
                        )
                    }
                }
            }
            
            viewModel.getServicesByCategoryId(serviceCategoryId: screenInfo.serviceCategory!.id!)
        }
    }
}
