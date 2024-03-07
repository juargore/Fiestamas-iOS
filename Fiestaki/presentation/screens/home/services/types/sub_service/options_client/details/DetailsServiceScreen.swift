//
//  ProvidersDetailsView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 13/06/23.
//

import SwiftUI

struct DetailsServiceScreen: View {
    
    @ObservedObject var viewModel = DetailsServiceViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: ServicesSelectionNavGraph
    
    var screenInfo: ScreenInfo
    
    @State var user: FirebaseUserDb? = nil
    @State var firebaseProviderDb: FirebaseUserDb? = nil
    @State private var showSuccessDialog = false
    @State private var showToast = false
    @State private var messageToast = ""
    @State private var showProgressDialog = false
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            
            VStack {
                servicesHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    title: screenInfo.service!.name,
                    subTitle: "",
                    showSubTitle: false
                ) {
                    navigation.navigateBack()
                }
                
                VStack {
                    ScrollView(.vertical) {
                        VStack {
                            if viewModel.service != nil {
                                if viewModel.service?.images != nil || viewModel.service?.videos != nil {
                                    if !viewModel.service!.images!.isEmpty || !viewModel.service!.videos!.isEmpty {
                                        PhotosGrid(service: viewModel.service!) {
                                            navigation.navigate(to: .onNavigatePhotoViewer(viewModel.service!.images!))
                                        }
                                        .frame(height: (UIScreen.height * 0.3) - 12)
                                    }
                                }

                                verifiedProvider
                                    .padding(.horizontal, 12)

                                Amenities(attributes: viewModel.attributes)
                                    .padding(.all, 8)

                                ProviderInfo(service: viewModel.service!) {
                                    if user == nil {
                                        debugPrint("AQUI: User is not logged in -> redirect to Auth")
                                        // TODO: Here
                                    } else {
                                        if screenInfo.role == Role.Unauthenticated {
                                            debugPrint("AQUI: previously was not logged, but now it is client -> create event")
                                            // previously was not logged, but now it is client -> create event
                                            if user?.uid != nil {
                                                showProgressDialog = true
                                                viewModel.createEventByClient(
                                                    clientId: user!.id!,
                                                    eventId: screenInfo.event!.id!,
                                                    questions: screenInfo.questions!,
                                                    onSuccess: { createEventResponse in
                                                        viewModel.addServiceToExistingEvent(
                                                            eventId: createEventResponse.id,
                                                            serviceId: screenInfo.service?.id ?? "",
                                                            onFinished: { success, message in
                                                                showProgressDialog = false
                                                                if success {
                                                                    showSuccessDialog = true
                                                                } else {
                                                                    messageToast = "Error al agregar servicio. Revise los logs."
                                                                    showToast = true
                                                                }
                                                            }
                                                        )
                                                    },
                                                    onFailure: { error in
                                                        showProgressDialog = false
                                                        messageToast = error.message
                                                        showToast = true
                                                    }
                                                )
                                            } else {
                                                debugPrint("AQUI: previously was not logged, but firebase.uid is null :(")
                                            }
                                        } else {
                                            // user is normal client
                                            showProgressDialog = true
                                            viewModel.addServiceToExistingEvent(
                                                eventId: screenInfo.clientEventId ?? "",
                                                serviceId: screenInfo.service?.id ?? "",
                                                onFinished: { success, message in
                                                    showProgressDialog = false
                                                    if success {
                                                        showSuccessDialog = true
                                                    } else {
                                                        messageToast = "Error al agregar servicio. Revise los logs."
                                                        showToast = true
                                                    }
                                                }
                                            )
                                        }
                                    }
                                }
                                .padding(.vertical, 8)
                                .padding(.horizontal, 12)

                                /*
                                Rectangle()
                                    .frame(height: 2)
                                    .padding(.horizontal, 8)
                                    .foregroundColor(.ashGray.opacity(0.5))

                                comments
                                    .padding(.all, 8)
                                */

                                Spacer()
                            }
                        }
                        .padding(.top, 10)
                    }
                }
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.7), radius: 5)
                .background(Color.white)
                .padding(12)
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .onAppear {
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
            }
            viewModel.getServiceDetails(serviceId: screenInfo.service!.id!, getAlsoAttributes: true) { service in
                authViewModel.getFirebaseProviderDb(providerId: service?.id_provider ?? "") { firebaseProvider in
                    self.firebaseProviderDb = firebaseProvider
                }
            }
        }
        .popUpDialog(isShowing: $showSuccessDialog, dialogContent: {
            let serviceTypeName = screenInfo.serviceCategory?.name ?? ""
            let serviceName = viewModel.service?.name  ?? "" // "La Fuente Rosa",
            let providerName = firebaseProviderDb?.name ?? ""
            let providerLastName = firebaseProviderDb?.last_name ?? ""
            let providerPhone = firebaseProviderDb?.phone_one  ?? ""
            //let providerEmail = firebaseProviderDb?.email ?? ""
            let serviceImage = viewModel.service?.image ?? viewModel.service?.images?[0] ?? ""
            
            SuccessDialog(
                serviceType: serviceTypeName,
                serviceName: serviceName,
                contactName: "\(providerName) \(providerLastName)",
                image: serviceImage,
                phone: providerPhone,
                email: "Mensaje",
                whatsapp: "Whatsapp",
                onPhoneClicked: {
                    showSuccessDialog = false
                    navigation.navigateToRoot()
                },
                onEmailClicked: {
                    showSuccessDialog = false
                    navigation.navigateToRoot()
                },
                onWhatsappClicked: {
                    showSuccessDialog = false
                    navigation.navigateToRoot()
                },
                onOkClicked: {
                    showSuccessDialog = false
                    navigation.navigateToRoot()
                }
            )
        })
        .popUpDialog(isShowing: $showProgressDialog, dialogContent: {
            ProgressDialog(isVisible: showProgressDialog)
        })
    }
}
    
    private var verifiedProvider: some View {
        HStack {
            Image(systemName: "checkmark")
            Text("PROVEEDOR VERIFICADO")
            Spacer()
        }
        .font(.tiny)
        .fontWeight(.w600)
        .foregroundColor(.hotPink)
    }

    struct PhotosGrid : View {
        
        var service: Service
        var onImageClicked: () -> Void
        
        var body: some View {
            VStack(spacing: 4) {
                let mHeight = ((UIScreen.height  * 0.3) / 2) - 16
                HStack {
                    if service.images?.count ?? 0 > 0 {
                        GridCardView(imageURL: service.images?[0] ?? "")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.width * 0.52, height: mHeight, alignment: .center)
                            .clipped()
                            .cornerRadius(8)
                    }

                    if service.images?.count ?? 0 > 1 {
                        GridCardView(imageURL: service.images?[1] ?? "")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.width * 0.36, height: mHeight, alignment: .center)
                            .clipped()
                            .cornerRadius(8)
                    }
                }

                HStack {
                    if service.images?.count ?? 0 > 2 {
                        GridCardView(imageURL: service.images?[2] ?? "")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.width * 0.16, height: mHeight, alignment: .center)
                            .clipped()
                            .cornerRadius(8)
                    }

                    if service.images?.count ?? 0 > 3 {
                        GridCardView(imageURL: service.images?[3] ?? "")
                            .aspectRatio(contentMode: .fill)
                            .frame(width: UIScreen.width * 0.45, height: mHeight, alignment: .center)
                            .clipped()
                            .cornerRadius(8)
                    }

                    if service.images?.count ?? 0 > 4 {
                        ZStack {
                            GridCardView(imageURL: service.images?[4] ?? "")
                                .aspectRatio(contentMode: .fill)
                                .frame(width: UIScreen.width * 0.24, height: mHeight, alignment: .center)
                                .clipped()
                                .cornerRadius(8)

                            if service.images?.count ?? 0 > 5 {
                                RoundedRectangle(cornerRadius: 10)
                                    .foregroundColor(.black.opacity(0.3))
                                    .frame(width: UIScreen.width * 0.24, height: mHeight, alignment: .center)

                                Text("+\((service.images?.count ?? 0) - 5)")
                                    .font(.medium)
                                    .fontWeight(.w600)
                                    .foregroundColor(.white)
                            }
                        }
                    }
                }
                .onTapGesture {
                    onImageClicked()
                }
            }
            .padding(.horizontal, 4)
        }
    }


struct Amenities: View {
    
    var attributes: [Attribute]
    
    var body: some View {
        ScrollView(.horizontal) {
            HStack {
                ForEach(attributes) { amenity in
                    VStack{
                        RemoteImage(urlString: amenity.icon)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)

                        Text(amenity.name)
                            .font(.tiny)
                            .lineLimit(2)
                            .multilineTextAlignment(.center)
                            .frame(width: 100)
                    }
                }
            }
        }
    }
}

struct ProviderInfo: View {
    
    var service: Service
    var onContactClicked: () -> Void
    @State private var readMore = false
    
    var body: some View {
        VStack() {
            HStack {
                Text(service.provider_name)
                    .font(.medium)
                    .fontWeight(.w700)
                    .foregroundColor(.black)
                    .multilineTextAlignment(.leading)
                    .padding(.bottom, 12)
                
                Spacer()
            }
            
            HStack(spacing: 3) {
                ForEach(1..<(service.rating), id: \.self) { _ in
                    Image(systemName: "star.fill")
                        .font(.tiny)
                        .foregroundColor(.hotPink)
                }
                Spacer()
            }
            .padding(.bottom, 10)
            
            HStack {
                Image(systemName: "mappin.and.ellipse")
                    .foregroundColor(.hotPink)

                Text(service.address)
                    .font(.small)
                    .fontWeight(.w700)
                    .foregroundColor(.hotPink)
                    .lineLimit(2)
                Spacer()
            }
            HStack {
                Text(service.description ?? "")
                    .lineLimit(readMore ? 12 : 5)
                    .font(.normal)
                    .fontWeight(.w500)
                    .padding(.top, 8)
                    .animation(.easeInOut, value: readMore)
                Spacer()
            }

            Button {
                readMore.toggle()
            } label: {
                HStack {
                    Text(readMore ? "Leer menos" : "Leer más")
                        .font(.normal)
                        .fontWeight(.w700)
                        .foregroundColor(.hotPink)
                        .padding(.top, 8)
                    Spacer()
                }
            }
            .padding(.top, -10)

            FiestakiButton(text: "CONTACTAR") {
                onContactClicked()
            }
            .padding(.top, 6)
            .padding(.bottom, 12)

            HStack {
                ZStack {
                    HStack {
                        Text("$ \(service.price)")
                            .font(.big)
                            .fontWeight(.w500)

                        Text("Por unidad")
                            .font(.tiny)
                            .fontWeight(.w600)
                    }
                }
                .padding(.vertical, 8)
                .padding(.horizontal, 18)
                .overlay(RoundedRectangle(cornerRadius: 8)
                .stroke(Color.ashGray, lineWidth: 1))
                
                VStack {
                    Text("Capacidad")
                        .font(.small)
                        .fontWeight(.w700)

                    Text("\(service.min_attendees) - \(service.max_attendees)")
                        .font(.regular)
                        .fontWeight(.w700)
                }
                .padding(.horizontal, 16)
                
                Spacer()
            }
        }
    }
}

    private var comments: some View {
        VStack(spacing: 16) {
            HStack {
                Text("Lo que más les gusto a los invitados")
                    .font(.normal)
                    .fontWeight(.w700)
                Spacer()
            }

            HStack {
                RemoteImage(urlString: "https://encrypted-tbn0.gstatic.com/images?q=tbn:ANd9GcSazCOtFAzVzT9CjeEAjIOjBh0KJAJbYuCOQancnlYx9ZH7uotKAMF0AtcW-iesNrVbzdU&usqp=CAU")
                    .scaledToFill()
                    .frame(width: 45 , height: 45)
                    .cornerRadius(25)
                VStack(alignment: .leading) {
                    Text("Bill Gates")
                        .font(.normal)
                        .fontWeight(.w700)
                    Text("Buen servicio y atención")
                        .font(.normal)
                }
                Spacer()
            }

            HStack {
                RemoteImage(urlString: "https://media.allure.com/photos/647f876463cd1ef47aab9c88/16:9/pass/angelina%20jolie%20blonde%20hair%20chloe.jpg")
                    .scaledToFill()
                    .frame(width: 45 , height: 45)
                    .cornerRadius(25)
                VStack(alignment: .leading) {
                    Text("Angie")
                        .font(.normal)
                        .fontWeight(.w700)
                    Text("Calidad y buen sazón!")
                        .font(.normal)
                }
                Spacer()
            }

            HStack {
                RemoteImage(urlString: "https://www.publimetro.com.mx/resizer/zXK8XvrtrlIumDJJMyf0yCHeK44=/arc-photo-metroworldnews/arc2-prod/public/RGIMI6UAH5B6FKCYG4GSF2REM4.jpg")
                    .scaledToFill()
                    .frame(width: 45 , height: 45)
                    .cornerRadius(25)
                VStack(alignment: .leading) {
                    Text("Paquita")
                        .font(.normal)
                        .fontWeight(.w700)
                    Text("Si lo recomiendo, sirven muy bien")
                        .font(.normal)
                }
                Spacer()
            }
        }
    }


struct GridCardView: View {
    var imageURL: String

    var body: some View {
        RemoteImage(urlString: imageURL)
            .cornerRadius(8)
            .clipped()
    }
}

struct Amenity: Identifiable, Hashable {
    var id = UUID()
    var imageURL: String
    var title: String
}

extension String: Identifiable {
    public var id: String {
        self
    }
}

