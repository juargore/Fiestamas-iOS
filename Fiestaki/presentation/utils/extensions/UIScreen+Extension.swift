//
//  UIScreen+Extension.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 14/05/23.
//

import UIKit
import SwiftUI

extension UIScreen {
    static let width = UIScreen.main.bounds.size.width
    static let height = UIScreen.main.bounds.size.height
    static let size = UIScreen.main.bounds.size
    
}

func backgroundLinearGradient(
    colors: [Color] = [.iceBlue, .white],
    startPoint: UnitPoint = .top,
    endPoint: UnitPoint = .bottom
) -> some View {
    LinearGradient(
        gradient: Gradient(colors: colors),
        startPoint: startPoint,
        endPoint: endPoint
    ).edgesIgnoringSafeArea(.top)
}

struct mainHeader: View {
    
    var userIsLoggedIn: Bool = false
    var username: String = ""
    var showBackButton: Bool = false
    var showCalendarIcon: Bool = false
    var showNotificationIcon: Bool = false
    var numberOfNotifications: Int = 0
    var iconNotification: String = "bellIcon"
    
    var onNotificationClicked: (() -> Void)? = nil
    var onCalendarClicked: (() -> Void)? = nil
    var onBackButtonClicked: (() -> Void)? = nil
    
    var body: some View {
        VStack {
            HStack {
                if showBackButton {
                    Button {
                        onBackButtonClicked?.self()
                    } label: {
                        Image(systemName: "chevron.left")
                            .font(.midRegular)
                            .fontWeight(.w600)
                            .foregroundColor(.hotPink)
                    }
                }
                
                Image("logo_fiestaki")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(height: 25)
                    .foregroundColor(.black)

                Spacer()

                if userIsLoggedIn {
                    Text(username)
                        .font(.small)
                        .fontWeight(.w400)
                        .foregroundColor(.black)
                }
                
                if showCalendarIcon {
                    Button {
                        onCalendarClicked?.self()
                    } label: {
                        Image("ic_calendar")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 25, height: 25)
                            .foregroundColor(.black)
                    }
                }
                
                if showNotificationIcon {
                    NotificationView(
                        numberOfNotifications: numberOfNotifications,
                        icon: iconNotification
                    ) {
                        onNotificationClicked?.self()
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct servicesHeader: View {
    
    var userIsLoggedIn: Bool = false
    var username: String = ""
    var title: String = ""
    var subTitle: String = ""
    var smallSubtitle: Bool = false
    var showSubTitle: Bool = true
    
    var onBackButtonClicked: () -> Void
    
    var body: some View {
        VStack {
            HStack {
                Button {
                    onBackButtonClicked()
                } label: {
                    Image(systemName: "chevron.left")
                        .font(.midRegular)
                        .fontWeight(.w600)
                        .foregroundColor(.hotPink)
                }
                
                Text(title)
                    .font(.medium)
                    .fontWeight(.w700)
                    .foregroundColor(.hotPink)
                    .lineLimit(1)
                    .multilineTextAlignment(.leading)

                Spacer()

                if userIsLoggedIn {
                    Text(username)
                        .font(.small)
                        .fontWeight(.w400)
                        .foregroundColor(.black)
                }
            }
            
            HStack {
                if showSubTitle {
                    var nSubTitle = subTitle
                    if nSubTitle.hasSuffix("- ") {
                        let _ = nSubTitle = String(nSubTitle.dropLast(2))
                    }
                    Text(nSubTitle)
                        .font(smallSubtitle ? .subheadline : .title2)
                        .foregroundColor(.black)
                    
                    Spacer()
                }
            }
            .padding(.top, 4)
            
        }
        .padding(.horizontal, 17)
    }
}


struct NotificationView: View {
    var numberOfNotifications: Int?
    var icon: String
    var onNotificationClicked: () -> Void
        
    var body: some View {
        ZStack(alignment: .topTrailing) {
            Button(action: {
                onNotificationClicked()
            }) {
                Image(icon)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 23, height: 23)
                    .foregroundColor(.black)
            }
            
            //if let notificationCount = numberOfNotifications, notificationCount > 0 {
                Circle()
                    .fill(Color.red)
                    .frame(width: 18, height: 18)
                    .overlay(
                        Text(String(numberOfNotifications ?? 0))
                            .foregroundColor(.white)
                            .font(.system(size: 11))
                            .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .center)
                    )
                    .offset(x: 6, y: -6)
            //}
        }
    }
}

struct WhiteBackgroundRoundedCorners: View {
    var body: some View {
        Rectangle()
            .cornerRadius(16)
            .shadow(color: .gray.opacity(0.4), radius: 5)
            .foregroundColor(Color.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
    }
}

struct EmptyScreenRedirectToLogin: View {
    var onNavigateLoginClicked: () -> Void
    var body: some View {
        HStack {
            Spacer()
            VStack {
                Spacer()
                Text("Inicia sesión para continuar")
                    .foregroundColor(.black)
                VStack {
                    Text("Iniciar sesión")
                        .foregroundColor(Color.white)
                        .padding()
                }
                .background(Color.blue)
                .cornerRadius(14)
                .onTapGesture {
                    onNavigateLoginClicked()
                }
                Spacer()
            }
            Spacer()
        }
    }
}
