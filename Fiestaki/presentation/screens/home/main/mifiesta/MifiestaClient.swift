//
//  MifiestaClient.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/13/23.
//

import Foundation
import SwiftUI

struct MifiestaClientContent: View {
    
    @ObservedObject var viewModel: MainPartyViewModel
    @ObservedObject var notifViewModel: NotificationsViewModel
    
    @State var selectedEvent: Event? = nil
    @State var colorVerticalList = Color.ashGray
    @State var showToast = false
    @State var messageToast = ""
    @State var showOrderBy = false
    
    var user: FirebaseUserDb
    var clientId: String
    var selectedDate: String
    
    var onNavigateHomeClicked: () -> Void
    var notifyTotalNotifications: (Int) -> Void
    var notifyEventList: ([CircleEventPerDay]) -> Void
    var onNavigateServicesCategoriesClicked: (ScreenInfo) -> Void
    var onNavigateServiceNegotiationClicked: (MyPartyService) -> Void

    var body: some View {
        ZStack {
            backgroundLinearGradient()
            VStack {
                ViewHorizontalMyParty(
                    shouldShowArrows: viewModel.horizontalListClient.count > 2,
                    horizontalList: viewModel.horizontalListClient,
                    onItemClicked: { myPartyEvent in
                        self.selectedEvent = myPartyEvent.toEvent()
                        self.colorVerticalList = Color(UIColor(hex: myPartyEvent.color_hex!))
                        viewModel.filterServiceListByEvent(eventId: myPartyEvent.id!)
                    },
                    onNewPartyClicked: {
                        self.onNavigateHomeClicked()
                    }
                )
                .padding(.horizontal, 10)
                
                HStack {
                    HStack {
                        Text("Agregar Servicios")
                            .foregroundColor(Color.hotPink)
                            .font(.caption)
                            .padding(.vertical, 7)
                            .padding(.leading, 8)
                        
                        Image("ic_add_green")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .padding(.trailing, 6)
                    }
                    .background(Color.white)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(RoundedRectangle(cornerRadius: 16).stroke(Color.ashGray, lineWidth: 0.8))
                    .onTapGesture {
                        if selectedEvent == nil {
                            messageToast = "Seleccione un evento arriba para agregar servicios"
                            showToast = true
                        } else {
                            let screenInfo = ScreenInfo(
                                role: Role.Client,
                                startedScreen: Screen.ServiceCategories,
                                prevScreen: Screen.Mifiesta,
                                event: selectedEvent,
                                questions: nil,
                                serviceCategory: nil,
                                clientEventId: selectedEvent?.clientEventId
                            )
                            onNavigateServicesCategoriesClicked(screenInfo)
                        }
                    }
                    
                    Spacer()
                    
                    if selectedEvent != nil {
                        VStack {
                            Text("Ver todos")
                                .foregroundColor(Color.hotPink)
                                .font(.tiny)
                            
                            Text("mis eventos")
                                .foregroundColor(Color.hotPink)
                                .font(.tiny)
                        }
                        .onTapGesture {
                            selectedEvent = nil
                            colorVerticalList = Color.ashGray
                            viewModel.getEventsWithServices(id: clientId)
                        }
                    }
                    
                    Spacer()
                    
                    HStack {
                        Text("Ordenar por")
                            .font(.subheadline)
                            .foregroundColor(.black)
                        
                        Image("ic_arrow_down")
                            .resizable()
                            .frame(width: 20, height: 20)
                    }
                    .onTapGesture {
                        showOrderBy = true
                    }
                }
                .padding(.horizontal, 14)
                
                VStack {
                    ScrollView(.vertical) {
                        VStack {
                            let mCircles = viewModel.horizontalListClient.toCircleEventPerDayList()
                            let _ = notifyEventList(mCircles)
                            
                            Rectangle()
                                .frame(height: 0)
                            
                            LazyVStack {
                                ForEach(viewModel.verticalListClient, id: \.self) { myPartyService in
                                    CardMyPartyVertical(item: myPartyService) { item in
                                        onNavigateServiceNegotiationClicked(item)
                                    }
                                    .padding(.horizontal, 6)
                                    .padding(.top, 3)
                                }
                            }
                            Spacer()
                        }
                    }
                }
                .background(colorVerticalList)
                .cornerRadius(10)
                .padding(.horizontal, 10)
                
            }
        }
        .toast(message: messageToast, isShowing: $showToast, duration: Toast.short)
        .onAppear {
            notifViewModel.getCountUnreadNotificationsByClientId(clientId: clientId) { counter in
                self.notifyTotalNotifications(counter)
            }
            viewModel.getEventsWithServices(id: clientId)
        }
        .sheet(isPresented: $showOrderBy) {
            BottomSheetServiceStateOrderBy { bottomServiceStatus in
                showOrderBy = false
                viewModel.sortClientServiceListByStatus(status: bottomServiceStatus.status, clientId: clientId)
            }
            .presentationDetents([.height(200), .height(200)])
            .presentationDragIndicator(.visible)
        }
    }
}

struct ViewHorizontalMyParty: View {
    
    var shouldShowArrows: Bool
    var horizontalList: [MyPartyEvent?]
    var onItemClicked: (MyPartyEvent) -> Void
    var onNewPartyClicked: () -> Void
        
    @State private var progress: Float = 0.5
    @State private var previousScrollOffset: CGFloat = 0
    @State private var scrollOffset: CGFloat = 0
    @State private var direction: String = ""
    @State private var showLeftArrow = false
    @State private var showRightArrow = false
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                HStack {
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHStack(spacing: 6) {
                            ForEach(horizontalList, id: \.self) { attr in
                                if let attr = attr {
                                    CardMyPartyHorizontal(item: attr) { myPartyEvent in
                                        onItemClicked(myPartyEvent)
                                    }
                                }
                            }
                        }
                        .background(
                            GeometryReader { innerGeometry -> Color in
                                DispatchQueue.main.async {
                                    let newScrollOffset = innerGeometry.frame(in: .global).minX
                                    if newScrollOffset > self.scrollOffset {
                                        self.direction = "right"
                                    } else if newScrollOffset < self.scrollOffset {
                                        self.direction = "left"
                                    }
                                    self.previousScrollOffset = self.scrollOffset
                                    self.scrollOffset = newScrollOffset
                                }
                                return Color.clear
                            }
                        )
                    }
                    .frame(height: 128)
                    .padding(8)
                    .onChange(of: direction) { newValue in
                        if newValue == "right" {
                            // user has scrolled to the right
                            showLeftArrow = true
                            showRightArrow = false
                        } else if newValue == "left" {
                            // user has scrolled to the left
                            showRightArrow = true
                            showLeftArrow = false
                        }
                    }
                    
                    Image("img_new_party")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 128)
                        .padding(.vertical, 8)
                        .padding(.trailing, 10)
                        .onTapGesture {
                            onNewPartyClicked()
                        }
                }
                .background(Color.white)
                .clipShape(RoundedRectangle(cornerRadius: 14))
                
                if shouldShowArrows {
                    HStack {
                        ZStack {
                            if showLeftArrow {
                                Circle()
                                    .foregroundColor(Color.black.opacity(0.6))
                                    .overlay {
                                        Image(systemName: "chevron.left")
                                            .foregroundColor(Color.white)
                                    }
                            }
                        }
                        .frame(width: 25, height: 25)
                        
                        Spacer()
                        
                        ZStack {
                            if showRightArrow {
                                Circle()
                                    .foregroundColor(Color.black.opacity(0.6))
                                    .overlay {
                                        Image(systemName: "chevron.right")
                                            .foregroundColor(Color.white)
                                    }
                            }
                        }
                        .frame(width: 25, height: 25)
                        
                        Spacer()
                            .frame(width: 100)
                    }
                    .frame(height: 128)
                    .padding(8)
                }
            }
        } // end geometry reader
        .frame(height: 150)
    }
}

struct CardMyPartyHorizontal: View {
    
    let item: MyPartyEvent?
    let onClick: (MyPartyEvent) -> Void

    var body: some View {
        if let item = item {
            let color = Color(UIColor(hex: item.color_hex ?? "#FFFFFF"))
            let progress: Float = 0.5

            ZStack {
                // Background Image
                RemoteImage(urlString: item.image ?? "")
                
                GradientTopAndRightToBottom(color: color)
                
                VStack() {
                    // Top Section
                    Text(item.name_event_type ?? "")
                        .font(.system(size: 15))
                        .foregroundColor(.white)
                        .lineLimit(1)
                        .truncationMode(.tail)
                    
                    VStack(alignment: .leading) {
                        HStack() {
                            // left content
                            VStack {
                                Text(item.name ?? "")
                                    .font(.system(size: 13))
                                    .foregroundColor(.white)
                            }
                            .frame(maxWidth: 45, maxHeight: .infinity, alignment: .center)
                            VStack {
                                RoundedRectangle(cornerRadius: 10)
                                    .fill(Color.white)
                                    .padding(4)
                                    .overlay(
                                        VStack() {
                                            Text("Avance")
                                                .font(.system(size: 9))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                            
                                            Text("50%")
                                                .font(.system(size: 18))
                                                .foregroundColor(color)
                                                .fontWeight(.bold)
                                            
                                            ProgressView(value: progress)
                                                .progressViewStyle(LinearProgressViewStyle(tint: color))
                                                .padding(.horizontal, 8)
                                            
                                            let finalCost: String = String(item.finalCost ?? 0)
                                            Text("$ \(finalCost)")
                                                .font(.system(size: 9))
                                                .fontWeight(.semibold)
                                                .foregroundColor(.black)
                                        }
                                    )
                            }
                            .frame(maxWidth: 95, maxHeight: .infinity, alignment: .center)
                            }
                        }
                    }
                    .padding(.horizontal, 8)
                    .padding(.top, 0)
                    .padding(.bottom, 20)
                    .frame(maxHeight: .infinity, alignment: .top)
                    
                    
                VStack(alignment: .center) {
                    // Bottom Section
                    Spacer()
                    HStack {
                        /*
                        Image(systemName: "clock")
                            .resizable()
                            .frame(width: 10, height: 10)
                        */
                        Text("Restan")
                            .font(.superTiny)
                            .foregroundColor(.black)
                        
                        Text(String(item.pendingDays ?? 0))
                            .font(.superTiny)
                            .fontWeight(.bold)
                            .foregroundColor(.black)
                        
                        Text("días")
                            .font(.superTiny)
                            .foregroundColor(.black)
                    }
                    .frame(width: 138)
                    .padding(4)
                    .background(Color(UIColor(hex: "#F1F2F2")))
                }
                
            } // end ZStack
            .frame(width: 140)
            .cornerRadius(10)
            .onTapGesture {
                onClick(item)
            }
        } // end item
    } // end some View
}


struct CardMyPartyVertical: View {
    
    let item: MyPartyService?
    let onClick: (MyPartyService) -> Void

    var body: some View {
        if let item = item {
            let color = Color(UIColor(hex: item.event_data?.color_hex ?? "#FFFFFF"))
            
            HStack {
                // Circle at start/left
                let status = item.status?.getStatus()
                Text("●")
                    .foregroundColor(status?.getStatusColor())
                    .font(.subheadline)
                    .padding(.horizontal, -5)

                // Middle image
                RemoteImage(urlString: item.image ?? "")
                    .frame(maxWidth: 100, maxHeight: 115)
                    .cornerRadius(10)
                    .aspectRatio(contentMode: .fill)

                // Information section
                VStack(alignment: .leading) {
                    
                    HStack {
                        let festejadosName = item.event_data?.name ?? ""
                        let eventName = item.event_data?.name_event_type ?? ""
                        Text("\(eventName) \(festejadosName)")
                            .font(.subheadline)
                            .foregroundColor(.white)
                            .padding(.horizontal, 10)
                            .fontWeight(.semibold)
                            .background(color)
                            .cornerRadius(6)

                        Spacer()
                    }
                    
                    Text(item.service_category_name ?? "")
                        .font(.reallyTiny)
                        .foregroundColor(.black)
                        .font(.system(size: 14))

                    HStack {
                        // Provider contact
                        VStack(alignment: .leading) {
                            Text(item.name ?? "")
                                .font(.subheadline)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .fontWeight(.semibold)
                                //.padding(.bottom, 0.5)
                            
                            Text("Contacto: \(item.provider_contact_name ?? "")")
                                .font(.tiny)
                                .foregroundColor(.black)
                                .lineLimit(1)
                                .padding(.bottom, -3)

                            HStack {
                                Image(systemName: "phone")
                                    .resizable()
                                    .frame(width: 12, height: 12)
                                    .foregroundColor(Color.hotPink)
                                    
                                Text(item.provider_contact_phone ?? "")
                                    .font(.caption)
                                    .foregroundColor(Color.hotPink)
                                    .lineLimit(1)
                            }
                            .padding(.horizontal, 8)
                            .padding(.vertical, 2)
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .strokeBorder(Color.hotPink, lineWidth: 0.5)
                            )
                        }
                        
                        Spacer()

                        // Cost per event
                        VStack {
                            RatingStar(rating: 5, size: 8)
                            VStack {
                                Text("Costo por evento")
                                    .font(.superTiny)
                                    .foregroundColor(.black)
                                Text("$ \(String(item.price ?? 0))")
                                    .font(.caption)
                                    .foregroundColor(.black)
                            }
                            .padding(8)
                            .overlay(
                                RoundedRectangle(cornerRadius: 8)
                                    .strokeBorder(Color.gray, lineWidth: 0.5)
                            )
                        }
                    }
                    .padding(.top, -10)

                    // Notes at bottom
                    HStack {
                        Text("●")
                            .foregroundColor(Color.hotPink)
                            .font(.caption)

                        Text(item.description ?? "")
                            .font(.caption2)
                            .lineLimit(1)
                            .foregroundColor(.black)
                    }
                }
            }
            .frame(maxWidth: .infinity)
            .padding(.horizontal, 8)
            .padding(.vertical, 12)
            .background(Color.white)
            .cornerRadius(10)
            .onTapGesture {
                onClick(item)
            }
        }
    }
}
