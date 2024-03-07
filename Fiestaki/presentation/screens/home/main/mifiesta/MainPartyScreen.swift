//
//  MyPartyScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 03/05/23.
//

import SwiftUI

struct MainPartyScreen: View {
    
    @ObservedObject var viewModel: MainPartyViewModel
    @ObservedObject var authViewModel: AuthViewModel
    
    @ObservedObject var serviceNegotiationViewModel = ServiceNegotiationViewModel()
    @ObservedObject var notificationsViewModel = NotificationsViewModel()
    
    @ObservedObject var navigationNegotiation = ServicesByEventsNavGraph()
    @ObservedObject var navigationServices = ServicesSelectionNavGraph()
    
    var onNavigateHomeClicked: () -> Void
    var onNavigateLoginClicked: () -> Void
    
    var appStorageManager = AppStorageManager()
    
    @State var user: FirebaseUserDb? = nil
    @State var totalNotif = 0
    @State var useNegotiationNavigation = true
    @State var showAdminServicesDialog = false
    @State var showCalendarSheet = false
    @State var circlesPerDay: [CircleEventPerDay] = []
    
    var minimumDate: Date {
        let calendar = Calendar.current
        let currentDate = calendar.startOfDay(for: Date())
        return currentDate
    }
    
    init(
        viewModel: MainPartyViewModel,
        authViewModel: AuthViewModel,
        onNavigateHomeClicked: @escaping () -> Void,
        onNavigateLoginClicked: @escaping () -> Void
    ) {
        self.viewModel = viewModel
        self.authViewModel = authViewModel
        
        self.onNavigateHomeClicked = onNavigateHomeClicked
        self.onNavigateLoginClicked = onNavigateLoginClicked
    }
    
    var body: some View {
        NavigationStack(path: useNegotiationNavigation ? $navigationNegotiation.navPath : $navigationServices.navPath) {
            ZStack {
                backgroundLinearGradient()
                    VStack {
                        mainHeader(
                            userIsLoggedIn: user != nil,
                            username: user?.name ?? "",
                            showCalendarIcon: user?.role?.getRole() != Role.Unauthenticated,
                            showNotificationIcon: user?.role?.getRole() != Role.Unauthenticated,
                            numberOfNotifications: totalNotif,
                            onNotificationClicked: {
                                let isProvider = user?.role?.isProvider()
                                var myPartyServiceList = viewModel.verticalListClient
                                if isProvider == true {
                                    myPartyServiceList = viewModel.servicesListProvider
                                }
                                useNegotiationNavigation = true
                                navigationNegotiation.navigate(to: .onNavigateNotificationsClicked(myPartyServiceList))
                            },
                            onCalendarClicked: {
                                showCalendarSheet = true
                            }
                        )
                        
                        if user?.role != "Unauthenticated" {
                            VStack {
                                if let currentUser = user {
                                    if currentUser.role?.isProvider() == true {
                                        MifiestaProviderContent(
                                            viewModel: viewModel,
                                            notifViewModel: notificationsViewModel,
                                            user: currentUser,
                                            providerId: currentUser.id ?? "",
                                            selectedDate: "",
                                            onNavigateHomeClicked: {
                                                self.onNavigateHomeClicked()
                                            },
                                            onTotalNotificationsGet: { counter in
                                                totalNotif = counter
                                            },
                                            notifyCirclesList: {
                                                
                                            },
                                            onNavigateServiceNegotiationClicked: { myPartyService in
                                                useNegotiationNavigation = true
                                                navigationNegotiation.navigate(to: .onNavigateServiceNegotiationClicked(myPartyService, true))
                                            }, onNavigateEditServiceClicked: { service in
                                                
                                            },
                                            onShowAdminServicesDialog: {
                                                showAdminServicesDialog = true
                                            })
                                    } else {
                                        MifiestaClientContent(
                                            viewModel: viewModel,
                                            notifViewModel: notificationsViewModel,
                                            user: currentUser,
                                            clientId: currentUser.id ?? "",
                                            selectedDate: "",
                                            onNavigateHomeClicked: {
                                                self.onNavigateHomeClicked()
                                            },
                                            notifyTotalNotifications: { counter in
                                                totalNotif = counter
                                            },
                                            notifyEventList: { circles in
                                                self.circlesPerDay = circles
                                            },
                                            onNavigateServicesCategoriesClicked: { screenInfo in
                                                useNegotiationNavigation = false
                                                navigationServices.navigate(to: .onNavigateServicesCategories(screenInfo))
                                            },
                                            onNavigateServiceNegotiationClicked: { myPartyService in
                                                useNegotiationNavigation = true
                                                navigationNegotiation.navigate(
                                                    to: .onNavigateServiceNegotiationClicked(myPartyService, false)
                                                )
                                            }
                                        )
                                    }
                                }
                                Spacer()
                            }
                        } else {
                            EmptyScreenRedirectToLogin {
                                onNavigateLoginClicked()
                            }
                        }
                    }
                    .navigationDestination(for: ServicesByEventsNavGraph.Destination.self) { destination in
                        switch destination {
                        case .onNavigateServiceNegotiationClicked(let myPartyService, let isProvider):
                            ServiceNegotiationScreen(
                                myPartyService: myPartyService, isProvider: isProvider)
                                .environmentObject(navigationNegotiation)
                        case .onNavigateNotificationsClicked(let myPartyServiceList):
                            NotificationsScreen(myPartyServiceList: myPartyServiceList, user: user)
                                .environmentObject(navigationNegotiation)
                        case .onNavigateChatScreen(let myPartyScreen, let clientId, let providerId, let serviceEventId, let serviceId, let isProvider, let clientEventId, let eventName):
                            ChatScreen(user: self.user, myPartyService: myPartyScreen, clientId: clientId, providerId: providerId, serviceEventId: serviceEventId, serviceId: serviceId, isProvider: isProvider, clientEventId: clientEventId, eventName: eventName)
                                .environmentObject(navigationNegotiation)
                        }
                    }
                    .environmentObject(navigationNegotiation)
                
                    .navigationDestination(for: ServicesSelectionNavGraph.Destination.self) { destination in
                        switch destination {
                        case .onNavigateServicesCategories(let screenInfo):
                            ServicesCategoriesScreen(screenInfo: screenInfo)
                                .environmentObject(navigationServices)
                        case .onNavigateServicesTypes(let screenInfo):
                            ServicesTypesScreen(screenInfo: screenInfo)
                                .environmentObject(navigationServices)
                        case .onNavigateSubServices(let screenInfo):
                            SubServicesScreen(screenInfo: screenInfo)
                                .environmentObject(navigationServices)
                        case .onNavigateAddServiceProvider1(let screenInfo, let serviceId):
                            AddEditProviderFirstStepScreen(serviceId: serviceId, screenInfo: screenInfo)
                                .environmentObject(navigationServices)
                        case .onNavigateAddServiceProvider2(let screenInfo, let serviceProviderData, let images, let videos, let isEditing):
                            AddEditProviderSecondStepScreen(isEditing: isEditing, screenInfo: screenInfo, images: images, videos: videos, serviceProviderData: serviceProviderData)
                                .environmentObject(navigationServices)
                        case .onNavigateServices(let screenInfo):
                            ServicesScreen(screenInfo: screenInfo)
                                .environmentObject(navigationServices)
                        case .onNavigateServiceDetail(let screenInfo):
                            DetailsServiceScreen(screenInfo: screenInfo)
                                .environmentObject(navigationServices)
                        case .onNavigatePhotoViewer(let images):
                            PhotoViewerScreen(gridImages: images)
                                .environmentObject(navigationServices)
                        }
                    }
                    .environmentObject(navigationServices)
            }
            .popUpDialog(isShowing: $showAdminServicesDialog, dialogContent: {
                AdminServicesDialog(
                    vm: viewModel,
                    allServicesProvider: viewModel.allServicesProvider,
                    servicesByEvents: viewModel.servicesListProvider,
                    onDismissDialog: {
                        showAdminServicesDialog = false
                    },
                    onNewServiceClicked: {
                        showAdminServicesDialog = false
                        onNavigateHomeClicked()
                    },
                    onEditServiceClicked: { service in
                        useNegotiationNavigation = false
                        navigationServices.navigate(to: .onNavigateAddServiceProvider1(nil, service.id))
                    }
                )
            })
        }
        .onAppear {
            appStorageManager.storeValue(false, for: StorageKeys.appFirstLaunch)
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
                // get services to show on admin services popup
                viewModel.getServicesByProviderId(providerId: self.user?.id ?? "")
                viewModel.getMyPartyServicesByProvider(providerId: self.user?.id ?? "") { _ in }
            }
        }
        .onChange(of: user) { newUserValue in
            guard newUserValue != nil else { return }
        }
        .sheet(isPresented: $showCalendarSheet) {
            VStack {
                CustomCalendarView(circlesPerDay: self.circlesPerDay)
            }
            .presentationDetents([.medium, .medium])
            .presentationDragIndicator(.visible)
        }
    }
}
