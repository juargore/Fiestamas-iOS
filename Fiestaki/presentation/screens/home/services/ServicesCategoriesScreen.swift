//
//  EventTypeDetailsView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 11/05/23.
//

import SwiftUI
import Foundation

struct ServicesCategoriesScreen: View {

    @ObservedObject var viewModel = ServicesCategoriesViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: ServicesSelectionNavGraph
    
    var screenInfo: ScreenInfo
    
    @State var user: FirebaseUserDb? = nil
    @State var eventCreated: CreateEventResponse? = nil
    @State var showToast = false
    @State var messageToast = ""
    @State var alreadyCreatedEvent: Bool
    @State var showProgressDialog = false

    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    init(
        screenInfo: ScreenInfo,
        alreadyCreatedEvent: Bool = false
    ) {
        self.screenInfo = screenInfo
        self.alreadyCreatedEvent = alreadyCreatedEvent
    }
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            
            VStack {
                servicesHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    title: screenInfo.event?.name ?? "",
                    subTitle: "Servicios"
                ) {
                    navigation.navigateBack()
                }
                
                ScrollView(.vertical) {
                    VStack {
                        servicesGrid
                            .padding(.horizontal, 16)
                    }
                }
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .onAppear {
            if screenInfo.role != Role.Unauthenticated {
                authViewModel.getFirebaseUserDb() { res in
                    self.user = res
                    
                    if screenInfo.role == Role.Client && screenInfo.prevScreen == Screen.Home {
                        if !alreadyCreatedEvent {
                            alreadyCreatedEvent = true
                            showProgressDialog = true
                            viewModel.createEventByClient(
                                clientId: self.user?.id ?? "",
                                eventId: screenInfo.event?.id ?? "",
                                questions: screenInfo.questions!,
                                onEventCreated: { response  in
                                    self.eventCreated = response
                                    showProgressDialog = false
                                }
                            )
                        }
                    }
                }
            }
            let eventId = viewModel.getEventId(screenInfo: screenInfo)
            viewModel.getServicesByEventId(eventId: eventId)
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .popUpDialog(isShowing: $showProgressDialog, dialogContent: {
            ProgressDialog(isVisible: showProgressDialog)
        })
    }

    var servicesGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.servicesByEvent) { serviceCategory in
                CardServiceCategory(title: serviceCategory.name ?? "", imageUrl: serviceCategory.icon) {
                    if screenInfo.prevScreen == Screen.Mifiesta {
                        navigation.navigate(to: .onNavigateServicesTypes(
                            viewModel.getNewScreenInfo(
                                screenInfo: screenInfo,
                                serviceCategory: serviceCategory,
                                questions: screenInfo.questions,
                                clientEventId: screenInfo.clientEventId)
                        ))
                    } else if screenInfo.prevScreen == Screen.Home {
                        switch screenInfo.role {
                        case Role.Provider:
                            navigation.navigate(to: .onNavigateServicesTypes(
                                viewModel.getNewScreenInfo(
                                    screenInfo: screenInfo,
                                    serviceCategory: serviceCategory,
                                    questions: nil,
                                    clientEventId: nil)
                            ))
                        case .Client:
                            if eventCreated?.id != nil {
                                navigation.navigate(to: .onNavigateServicesTypes(
                                    viewModel.getNewScreenInfo(
                                        screenInfo: screenInfo,
                                        serviceCategory: serviceCategory,
                                        questions: screenInfo.questions,
                                        clientEventId: eventCreated!.id)
                                ))
                            } else {
                                messageToast = "Error: ClientEvent is nil"
                                showToast = true
                            }
                        case .Unauthenticated:
                            navigation.navigate(to: .onNavigateServicesTypes(
                                viewModel.getNewScreenInfo(
                                    screenInfo: screenInfo,
                                    serviceCategory: serviceCategory,
                                    questions: screenInfo.questions,
                                    clientEventId: nil)
                            ))
                        }
                    }
                }
                .frame(width: UIScreen.width / 3 - 15)
            }
        }
    }
}
