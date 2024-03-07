//
//  HomeScreen.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 03/05/23.
//

import SwiftUI
import Firebase

struct MainHomeScreen: View {

    @ObservedObject var viewModel: MainHomeViewModel
    @ObservedObject var authViewModel: AuthViewModel
    @ObservedObject var serviceCategoriesViewModel = ServicesCategoriesViewModel()
    @ObservedObject var navigation = ServicesSelectionNavGraph()
    @StateObject var notificationManager = NotificationManager()
    
    var redirectToMyParty: () -> Void
    
    @State var isQuestionsDialogForProvider = false
    @State var isPressed = false
    @State var user: FirebaseUserDb? = nil
    @State var showQuestionsDialog = false
    @State var selectedEvent: Event? = nil
    @State var selectedServiceCategory: ServiceCategory? = nil
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    let categoriesColumns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]

    var body: some View {
        NavigationStack(path: $navigation.navPath) {
            ZStack {
                backgroundLinearGradient()
                VStack {
                    mainHeader(
                        userIsLoggedIn: user != nil,
                        username: user?.name ?? "",
                        showNotificationIcon: false
                    )
                    ScrollView(.vertical) {
                        VStack {
                            topBanner()

                            if user?.role?.getRole() != Role.Provider {
                                eventTypes
                                    .padding(.horizontal, 12)
                                    .padding(.top, 8)
                            }

                            servicesTitle
                                .padding(.top, 16)
                                .padding(.horizontal, 16)

                            serviceCategories
                                .padding(.horizontal, 16)
                                .padding(.top, -8)
                            
                            footer
                                .padding(.top, 10)
                        }
                    }
                }
                .navigationDestination(for: ServicesSelectionNavGraph.Destination.self) { destination in
                    switch destination {
                    case .onNavigateServicesCategories(let screenInfo):
                        ServicesCategoriesScreen(screenInfo: screenInfo)
                            .environmentObject(navigation)
                    case .onNavigateServicesTypes(let screenInfo):
                        ServicesTypesScreen(screenInfo: screenInfo)
                            .environmentObject(navigation)
                    case .onNavigateSubServices(let screenInfo):
                        SubServicesScreen(screenInfo: screenInfo)
                            .environmentObject(navigation)
                    case .onNavigateAddServiceProvider1(let screenInfo, let serviceId):
                        AddEditProviderFirstStepScreen(serviceId: serviceId, screenInfo: screenInfo)
                            .environmentObject(navigation)
                    case .onNavigateAddServiceProvider2(let screenInfo, let serviceProviderData, let images, let videos, let isEditing):
                        AddEditProviderSecondStepScreen(isEditing: isEditing, screenInfo: screenInfo, images: images, videos: videos, serviceProviderData: serviceProviderData)
                            .environmentObject(navigation)
                    case .onNavigateServices(let screenInfo):
                        ServicesScreen(screenInfo: screenInfo)
                            .environmentObject(navigation)
                    case .onNavigateServiceDetail(let screenInfo):
                        DetailsServiceScreen(screenInfo: screenInfo)
                            .environmentObject(navigation)
                    case .onNavigatePhotoViewer(let images):
                        PhotoViewerScreen(gridImages: images)
                            .environmentObject(navigation)
                    }
                }
                .environmentObject(navigation)
            }
            .popUpDialog(isShowing: $showQuestionsDialog, dialogContent: {
                FirstQuestionsDialog(
                    vms: serviceCategoriesViewModel,
                    isForProvider: isQuestionsDialogForProvider,
                    serviceCategory: selectedServiceCategory,
                    onContinueClicked: { questions, event in
                        showQuestionsDialog = false
                        
                        if event != nil {
                            // if event != null -> Service clicked
                            let screenInfo = ScreenInfo(
                                role: user?.role?.getRole() ?? Role.Client,
                                startedScreen: Screen.ServiceTypes,
                                prevScreen: Screen.Home,
                                event: event,
                                questions: questions,
                                serviceCategory: selectedServiceCategory,
                                clientEventId: nil
                            )
                            navigation.navigate(to: .onNavigateServicesTypes(screenInfo))
                        } else {
                            // if event == null -> Event clicked
                            let screenInfo = ScreenInfo(
                                role: user?.role?.getRole() ?? Role.Client,
                                startedScreen: Screen.ServiceCategories,
                                prevScreen: Screen.Home,
                                event: selectedEvent!,
                                questions: questions,
                                serviceCategory: nil,
                                clientEventId: nil
                            )
                            navigation.navigate(to: .onNavigateServicesCategories(screenInfo))
                        }
                    }, onDismissDialog: {
                        showQuestionsDialog = false
                    }
                )
                .frame(height: selectedServiceCategory != nil ? 520 : 480)
            })
        }
        .toolbar(.hidden, for: .navigationBar)
        .onAppear {
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
                if viewModel.shouldRedirectToMyParty() && self.user?.role?.getRole() != Role.Unauthenticated {
                    redirectToMyParty()
                } else {
                    viewModel.getEventTypes()
                    viewModel.getServiceCategories()
                }
            }
            // notification push permissions
            /*Task {
                await notificationManager.request()
            }*/
        }
        /*.disabled(notificationManager.hasPermission)
        .task {
            await notificationManager.getAuthStatus()
        }*/
    }

    struct topBanner: View {
        var body: some View {
            Image("fiestakiBanner")
                .resizable()
                .aspectRatio(contentMode: .fill)
                .frame(height: UIScreen.height / 6)
                .cornerRadius(10)
                .padding(.top, 10)
                .padding(.horizontal, 16)
        }
    }

    var eventTypes: some View {
        LazyVGrid(columns: columns, spacing: 14) {
            ForEach(viewModel.eventTypes, id: \.self) { eventType in
                RemoteImage(urlString: eventType.image ?? "")
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.width / 2 - 20, height: UIScreen.height / 3.75)
                    .clipped()
                    .cornerRadius(8)
                    .shadow(color: .gray, radius: 10)
                    //.overlay { EventTypeTitle(title: eventType.name) }
                    .onTapGesture {
                        showQuestionsDialog = true
                        selectedEvent = eventType
                        selectedServiceCategory = nil
                    }
            }
        }
    }

    var servicesTitle: some View {
        Text("Servicios Individuales")
            .font(.medium)
            .fontWeight(.w800)
            .foregroundColor(.black)
    }

    var serviceCategories: some View {
        LazyVGrid(columns: categoriesColumns, spacing: 10) {
            ForEach(viewModel.serviceCategories, id: \.self) { serviceCategory in
                CardServiceCategory(title: serviceCategory.name ?? "", imageUrl: serviceCategory.icon) {
                    // if user -> Show popup
                    if authViewModel.getUserRole(self.user) == Role.Client ||
                        authViewModel.getUserRole(self.user) == Role.Unauthenticated
                    {
                        selectedEvent = nil
                        selectedServiceCategory = serviceCategory
                        showQuestionsDialog = true
                    } else {
                        // if provider -> go to next screen
                        let screenInfo = ScreenInfo(
                            role: Role.Provider,
                            startedScreen: Screen.ServiceTypes,
                            prevScreen: Screen.Home,
                            event: Event(id: "b26WVIm9RcEvXtqfiYDe"), // phantom event
                            questions: nil,
                            serviceCategory: serviceCategory,
                            clientEventId: nil
                        )
                        navigation.navigate(to: .onNavigateServicesTypes(screenInfo))
                    }
                }
                .frame(width: UIScreen.width / 3 - 15)
            }
        }
    }

    var footer: some View {
        ZStack {
            Rectangle()
                .fill(Color.white)
                .frame(height: 100)

            VStack {
                Text("Encuéntranos")
                    .font(.small)
                    .fontWeight(.w600)

                HStack (spacing: 38) {
                    Image("instagramIcon")
                        .resizable()
                        .frame(width: 30 , height: 30)
                        .onTapGesture {
                            openURLInBrowser("https://www.instagram.com/fiestamasapp/")
                        }
                    Image("facebookIcon")
                        .resizable()
                        .frame(width: 30 , height: 30)
                        .onTapGesture {
                            openURLInBrowser("https://www.facebook.com/FiestamasApp")
                        }
                    Image("pinterestIcon")
                        .resizable()
                        .frame(width: 30 , height: 30)
                        .onTapGesture {
                            openURLInBrowser("https://www.pinterest.com.mx/FiestamasApp/")
                        }
                    Image("twitchIcon")
                        .resizable()
                        .frame(width: 30 , height: 30)
                        .onTapGesture {
                            openURLInBrowser("https://www.twitch.tv/fiestamas")
                        }
                    Image("tiktokIcon")
                        .resizable()
                        .frame(width: 30 , height: 30)
                        .onTapGesture {
                            openURLInBrowser("https://www.tiktok.com/@fiestamasapp")
                        }
                }
            }
            .background(Color.clear)
        }
    }
    
} // End of HomeScreen


struct EventTypeTitle: View {
    var title: String?
    var body: some View {
        VStack {
            Spacer()
            ZStack {
                Text(title?.uppercased() ?? "")
                    .font(.overNormal)
                    .fontWeight(.w900)
                    .foregroundColor(.hotPink)
                    .padding(.all, 8)
                    .lineLimit(2)
                    .minimumScaleFactor(0.5)
            }
            .frame(width: UIScreen.width / 2 - 50, height: 45)
            .background(Color.white)
            .cornerRadius(24)
            .padding(.all, 16)
        }

    }
}

struct ServiceCategoryCard: View {

    var imageUrl: String?
    var title: String?

    var body: some View {
        ZStack {
            RoundedRectangle(cornerRadius: 23)
                .stroke(lineWidth: 1)
                .foregroundColor(.black)
                .frame(height: 50)

            HStack(spacing: 12) {
                RemoteImage(urlString: imageUrl ?? "")
                    .frame(width: 24, height: 24)

                Text(title ?? "")
                    .font(.normal)
                    .fontWeight(.w700)
                    .foregroundColor(.primary)
            }
            .padding(.horizontal, 12)
        }
    }
}
