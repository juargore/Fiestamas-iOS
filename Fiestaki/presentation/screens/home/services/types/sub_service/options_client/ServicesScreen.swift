//
//  AvailableProvidersView.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 11/06/23.
//

import SwiftUI

struct ServicesScreen: View {

    @ObservedObject var viewModel = ServicesViewModel()
    @ObservedObject var authViewModel = AuthViewModel()
    @EnvironmentObject var navigation: ServicesSelectionNavGraph
    
    var screenInfo: ScreenInfo
    
    @State var user: FirebaseUserDb? = nil
    @State private var showToast = false
    @State private var messageToast = ""
    
    @State private var speed = 50.0
    @State private var isEditing = false

    let columns = [
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
                
                VStack {
                    ScrollView(.vertical) {
                        VStack {
                            /*
                            HStack {
                                Text("Cercanía")
                                    .font(.small)
                                    .fontWeight(.w700)
                                
                                Button {
                                    //viewModel.decrementSlider()
                                } label: {
                                    Image(systemName: "minus.circle")
                                        .font(.overNormal)
                                        .foregroundColor(.black)
                                }
                                
                                Slider(
                                    value: $speed,
                                    in: 0...100,
                                    onEditingChanged: { editing in
                                        isEditing = editing
                                    }
                                )
                                .tint(Color.hotPink)
                                .frame(width: 150)
                                
                                Button {
                                    //viewModel.incrementSlider()
                                } label: {
                                    Image(systemName: "plus.circle")
                                        .font(.overNormal)
                                        .foregroundColor(.black)
                                }
                                
                                Spacer()
                            }
                            .padding(.top, 10)
                            .padding(.leading, 10)
                            
                            HStack {
                                Text("Ordenar por")
                                    .font(.subheadline)
                                Image("ic_arrow_down")
                                    .resizable()
                                    .frame(width: 20, height: 20)
                                Spacer()
                            }
                            .onTapGesture {
                                
                            }
                            .padding(.horizontal, 10)
                            */
                            
                            providersGrid.padding(.all, 8)
                            
                            Spacer()
                            
                        }
                        .padding(.all, 16)
                    }
                }
                .cornerRadius(10)
                .shadow(color: .gray.opacity(0.7), radius: 5)
                .background(Color.lavenderMist)
                .padding(.all, 12)
                .overlay {
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(lineWidth: 2)
                        .foregroundColor(.hotPink)
                        .shadow(color: .gray.opacity(0.7), radius: 5)
                        .padding(.all, 12)
                }
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .onAppear {
            authViewModel.getFirebaseUserDb() { res in
                self.user = res
            }
            viewModel.getServicesAccordingData(screenInfo: screenInfo, onError: { message in
                messageToast = message
                showToast = true
            })
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }

    private var providersGrid: some View {
        LazyVGrid(columns: columns, spacing: 10) {
            ForEach(viewModel.servicesByType, id: \.self) { service in
                VStack {
                    RemoteImage(urlString: service.image)
                        .aspectRatio(contentMode: .fill)
                        .frame(width: UIScreen.width / 2 - 30, height: UIScreen.height * 0.15)
                        .cornerRadius(8)
                        .shadow(color: .gray.opacity(0.5), radius: 5)

                    ZStack {
                        Rectangle()
                            .foregroundColor(Color.white)
                            .cornerRadius(8, corners: [.bottomLeft, .bottomRight])

                        VStack {
                            HStack {
                                Text(service.name)

                                Spacer()

                                Image(systemName: "heart")
                                    .font(.overNormal)
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 20)

                            HStack(spacing: 3) {
                                ForEach(1..<(service.rating), id: \.self) { _ in
                                    Image(systemName: "star.fill")
                                        .font(.tiny)
                                        .foregroundColor(.hotPink)
                                }
                                /*
                                Image(systemName: "checkmark")
                                    .fontWeight(.w600)
                                    .foregroundColor(.hotPink)
                                */

                                Spacer()

                                Image(systemName: "plus")
                                    .font(.regular)
                                    .fontWeight(.w600)
                                    .foregroundColor(.hotPink) 
                                    .padding(.bottom, -30)
                            }
                            .padding(.top, 8)
                            .padding(.horizontal, 8)
                            .padding(.bottom, 30)
                        }

                    }
                    .frame(width: UIScreen.width / 2 - 30)
                    .shadow(color: .gray.opacity(0.5), radius: 5)
                    .padding(.top, -16)
                }
                .padding(.vertical, 2)
                .onTapGesture {
                    //let nService = Service(id: service.id!, name: service.name)
                    let mScreenInfo = ScreenInfo(
                        role: screenInfo.role,
                        startedScreen: screenInfo.startedScreen,
                        prevScreen: screenInfo.prevScreen,
                        event: screenInfo.event,
                        questions: screenInfo.questions,
                        serviceCategory: screenInfo.serviceCategory,
                        clientEventId: screenInfo.clientEventId,
                        serviceType: screenInfo.serviceType,
                        subService: screenInfo.subService,
                        service: service
                    )
                    navigation.navigate(to: .onNavigateServiceDetail(mScreenInfo))
                }
            }
        }
    }
}

extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape( RoundedCorner(radius: radius, corners: corners) )
    }
}

struct RoundedCorner: Shape {

    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners

    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect, byRoundingCorners: corners, cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}
