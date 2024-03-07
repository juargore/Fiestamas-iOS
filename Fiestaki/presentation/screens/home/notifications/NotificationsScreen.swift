//
//  NotificationsScreen.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/15/23.
//

import SwiftUI
import Foundation

struct NotificationsScreen: View {
    
    @ObservedObject var authViewModel = AuthViewModel()
    @ObservedObject var viewModel = NotificationsViewModel()
    @EnvironmentObject var navigation: ServicesByEventsNavGraph
    
    var myPartyServiceList: [MyPartyService]
    var user: FirebaseUserDb? = nil
    
    init(myPartyServiceList: [MyPartyService], user: FirebaseUserDb?) {
        self.user = user
        self.myPartyServiceList = myPartyServiceList
        
        viewModel.getMessagesNotificationsByUserId(
            isProvider: user?.role?.isProvider(),
            userId: user?.id,
            myPartyServiceList: self.myPartyServiceList
        )
    }
    
    var body: some View {
        ZStack {
            backgroundLinearGradient()
            VStack {
                mainHeader(
                    userIsLoggedIn: user != nil,
                    username: user?.name ?? "",
                    showBackButton: true,
                    onBackButtonClicked: {
                        navigation.navigateBack()
                    }
                )
                
                HStack {
                    Text("Notificaciones")
                        .font(.largeTitle)
                        .foregroundColor(Color.black)
                    Spacer()
                }
                .padding(.horizontal, 12)
                
                ScrollView(.vertical) {
                    VStack {
                        LazyVStack {
                            ForEach(viewModel.notificationServerList, id: \.self) { notification in
                                CardNotification(item: notification) { item in
                                    let myPartyService = item.serviceEvent!
                                    navigation.navigate(
                                        to: .onNavigateChatScreen(
                                            myPartyService: myPartyService,
                                            clientId: myPartyService.id_client ?? "",
                                            providerId: myPartyService.id_provider ?? "",
                                            serviceEventId: myPartyService.id ?? "",
                                            serviceId: myPartyService.id_service ?? "",
                                            isProvider: user?.role?.isProvider() ?? false,
                                            clientEventId: myPartyService.id_client_event ?? "",
                                            eventName: "\(myPartyService.event_data?.name_event_type ?? "") \(myPartyService.event_data?.name ?? "")"
                                        )
                                    )
                                }
                            }
                        }
                        .background(Color.white)
                        .cornerRadius(10)
                        //.fixedSize(horizontal: false, vertical: true)
                        .padding(.horizontal, 12)
                        
                        Spacer()
                    }
                }
                
                
            }
        }
        .toolbar(.hidden, for: .navigationBar)
        .toolbar(.hidden, for: .tabBar)
    }
}


struct CardNotification: View {
    var item: Notification?
    var onClick: (Notification) -> Void

    var body: some View {
        if let item = item {
            HStack {
                // Circle at start/left
                let circleColor = item.status == NotificationStatus.Read ? Color.white : Color.red
                let circleBorderColor = item.status == NotificationStatus.Read ? Color.ashGray : Color.clear

                Circle()
                    .fill(circleColor)
                    .overlay(Circle().stroke(circleBorderColor, lineWidth: 1))
                    .frame(width: 12, height: 12)

                // Middle image
                RemoteImage(urlString: item.icon ?? "")
                    .aspectRatio(contentMode: .fill)
                    .clipShape(Circle())
                    .overlay(Circle().stroke(Color.ashGray, lineWidth: 0.2))
                    .frame(width: 60, height: 60)


                // Third space for information
                VStack(alignment: .leading) {
                    HStack {
                        Text("\(item.eventType ?? "") \(item.festejadosName ?? "")")
                            .font(.system(size: 14, weight: .semibold))
                            .foregroundColor(.black)

                        Spacer()

                        //let date = convertDateToDateAndHour(date: item.date)
                        //Text(item.date ?? "")
                            //.font(.reallyTiny)
                            //.font(.system(size: 11))
                            //.foregroundColor(Color.primary)
                    }

                    VStack(alignment: .leading, spacing: 2) {
                        Text("\(item.eventName ?? "") - \(item.serviceName ?? "")")
                            .font(.system(size: 12, weight: .semibold))
                            .lineLimit(1)
                            .truncationMode(.tail)
                            .foregroundColor(.black)

                        let message = item.message.starts(with: "https://") ? "Imagen multimedia" : item.message

                        Text(message)
                            .font(.system(size: 13))
                            .foregroundColor(Color.pink)
                            .lineLimit(1)
                            .truncationMode(.tail)
                    }
                }
                .frame(width: (UIScreen.width / 2) - 20)
                
                VStack(alignment: .trailing) {
                    HStack {
                        Text(item.date ?? "")
                            .font(.system(size: 8))
                            .lineLimit(1)
                            .foregroundColor(Color.primary)
                    }
                    
                    HStack {
                        Image(systemName: "arrow.right")
                            .resizable()
                            .frame(width: 15, height: 15)
                            .foregroundColor(.black)
                    }
                }
                
            } // end Hstack
            .frame(maxWidth: .infinity, maxHeight: 80)
            .background(Color.white)
            .cornerRadius(10)
            .onTapGesture {
                onClick(item)
            }
            .padding(12)
        }
    }
}
