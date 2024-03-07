//
//  MifiestaProvider.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/13/23.
//

import SwiftUI

struct MifiestaProviderContent: View {
    
    @ObservedObject var viewModel: MainPartyViewModel
    @ObservedObject var notifViewModel: NotificationsViewModel
    
    var user: FirebaseUserDb
    
    var providerId: String
    var selectedDate: String
    var onNavigateHomeClicked: () -> Void
    var onTotalNotificationsGet: (Int) -> Void
    var notifyCirclesList: () -> Void
    var onNavigateServiceNegotiationClicked: (MyPartyService) -> Void
    var onNavigateEditServiceClicked: (Service) -> Void
    var onShowAdminServicesDialog: () -> Void
    
    let columns = [
        GridItem(.flexible()),
        GridItem(.flexible()),
        GridItem(.flexible())
    ]
    
    var body: some View {
        ZStack {
            VStack {
                HStack {
                    VStack(alignment: HorizontalAlignment.leading) {
                        Text(viewModel.titleService)
                            .foregroundColor(.black)
                        
                        HStack(spacing: 0) {
                            ForEach(0..<(5), id: \.self) { _ in
                                Image(systemName: "star.fill")
                                    .font(.tiny)
                                    .foregroundColor(.hotPink)
                                    .padding(.vertical, 0.5)
                            }
                        }
                        HStack {
                            Text("Adminsitración de mis servicios")
                                .foregroundColor(Color.white)
                                .font(.caption)
                                .padding(6)
                        }
                        .background(Color.hotPink)
                        .cornerRadius(12)
                        .onTapGesture {
                            onShowAdminServicesDialog()
                        }
                    }
                    Spacer()
                }
                if viewModel.servicesListProvider.count == 1 {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.oneElementList, id: \.self) { servicesList in
                            NewCardEventProvider {
                                self.onNavigateHomeClicked()
                            }
                        }
                    }
                    Spacer()
                } else {
                    LazyVGrid(columns: columns, spacing: 14) {
                        ForEach(viewModel.servicesListProvider, id: \.self) { item in
                            CardServiceProvider(
                                item: item,
                                onClick: { myPartyService in
                                    self.onNavigateServiceNegotiationClicked(myPartyService)
                                },
                                onNewEventClick : {
                                    self.onNavigateHomeClicked()
                                }
                            )
                        }
                    }
                    Spacer()
                }
            }
        }
        .padding(10)
        .onAppear {
            viewModel.getMyPartyServicesByProvider(providerId: providerId) { services in
                notifViewModel.getCountUnreadNotificationsByProviderId(providerId: providerId, myPartyServiceList: services) { counter in
                    self.onTotalNotificationsGet(counter)
                }
            }
        }
    }
}

struct NewCardEventProvider: View {
    
    var onClick: () -> Void
    
    var body: some View {
        VStack {
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(Color(UIColor(hex: "#FDE9F0")))
                    .frame(height: 190)
                    .overlay(
                        RoundedRectangle(cornerRadius: 10)
                            .strokeBorder(Color.pink, lineWidth: 2)
                    )
                
                Image("img_new_event")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 85)
            }
        }
        .onTapGesture {
            onClick()
        }
        .frame(height: 190)
        .padding(EdgeInsets(top: 2, leading: 5, bottom: 2, trailing: 5))
    }
}

struct CardServiceProvider: View {
    
    var item: MyPartyService
    var onClick: (MyPartyService) -> Void
    var onNewEventClick: () -> Void

    var body: some View {
        if item.id != nil {
            let color = Color(UIColor(hex: item.event_data?.color_hex ?? "#FFFFFF"))

            ZStack {
                // Background image + gradient color
                ZStack {
                    RemoteImage(urlString: item.image ?? "")
                        .frame(maxHeight: .infinity)
                        .clipped()
                    
                    GradientTopAndRightToBottom(color: color)
                }
                .onTapGesture {
                    onClick(item)
                }
                
                VStack {
                    // Content
                    VStack(alignment: .leading, spacing: 4) {
                        Text(item.event_data?.name_event_type ?? "")
                            .font(.system(size: 14))
                            .foregroundColor(.white)
                            .lineLimit(2)
                        
                        Text(item.event_data?.name ?? "")
                            .font(.system(size: 13))
                            .foregroundColor(.white)
                            .lineLimit(1)
                        
                        HStack {
                            Spacer()
                            let mDate = convertStringToDate(item.date)
                            VStack(alignment: .leading, spacing: 2) {
                                let pairDate = convertDateToDateAndWeekDay(date: mDate)
                                Text(pairDate.0)
                                    .font(.system(size: 9))
                                    .foregroundColor(Color.black)
                                Text(pairDate.1)
                                    .font(.system(size: 9))
                                    .foregroundColor(.black)
                            }
                            
                            Spacer()
                            
                            VStack(alignment: .leading, spacing: 2) {
                                let (_, hour) = convertDateToDateAndHour(date: mDate)
                                Text(hour.replacingOccurrences(of: "hrs", with: ""))
                                    .font(.system(size: 9))
                                    .foregroundColor(.black)
                                Text("HRS")
                                    .font(.system(size: 9))
                                    .foregroundColor(.black)
                            }
                            Spacer()
                        }
                        .padding(.horizontal, 4)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(10)
                        
                        VStack(alignment: .leading, spacing: 2) {
                            HStack {
                                Text(item.service_category_name ?? "")
                                    .font(.system(size: 9))
                                    .foregroundColor(.black)
                                Spacer()
                            }
                            Text("✔ \(item.name ?? "")")
                                .font(.system(size: 9))
                                .lineLimit(1)
                                .foregroundColor(.black)
                        }
                        .padding(.horizontal, 12)
                        .padding(.vertical, 8)
                        .background(Color.white)
                        .cornerRadius(10)
                    }
                    .padding(4)
                } // end VStack
                
                // Bottom section
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 10, height: 10)
                            .foregroundColor(color)
                        
                        let nDate = convertStringToDate(item.date)
                        let pendingDays = daysUntilDate(nDate)
                        let wording = pendingDays > -1 ? "Resta" : "Fue hace"
                        
                        Text(wording)
                            .font(.system(size: 9))
                            .foregroundColor(.black)
                        
                        Text("\(abs(pendingDays))")
                            .font(.system(size: 10))
                            .foregroundColor(color)
                        
                        Text("dias")
                            .font(.system(size: 9))
                            .foregroundColor(.black)
                        
                        Spacer()
                    }
                    .padding(.vertical, 5)
                    .background(Color.white)
                }
                
                // Circle status color
                let status = item.status?.getStatus()
                Circle()
                    .frame(width: 28, height: 28)
                    .foregroundColor(status?.getStatusColor())
                    .overlay(
                        Circle()
                            .stroke(Color.white, lineWidth: 3)
                    )
                    .position(x: 15, y: 15)
            }
            .frame(height: 190)
            .cornerRadius(12)
            .padding(4)
            
        } else {
            NewCardEventProvider {
                onNewEventClick()
            }
        }
    }
}


struct GradientTopAndRightToBottom: View {
    let color: Color

    var body: some View {
        ZStack {
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: color, location: 0),
                    .init(color: .clear, location: 1)
                ]),
                startPoint: .top,
                endPoint: .bottom
            )
            LinearGradient(
                gradient: Gradient(stops: [
                    .init(color: .clear, location: 0),
                    .init(color: color, location: 1)
                ]),
                startPoint: .leading,
                endPoint: .trailing
            )
        }
        .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}
