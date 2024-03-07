//
//  ServicesByEventsNavGraph.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/13/23.
//

import Foundation
import SwiftUI

final class ServicesByEventsNavGraph : ObservableObject {
    
    public enum Destination: Codable, Hashable {
        case onNavigateServiceNegotiationClicked(MyPartyService, Bool)
        case onNavigateNotificationsClicked([MyPartyService])
        case onNavigateChatScreen(
            myPartyService: MyPartyService,
            clientId: String,
            providerId: String,
            serviceEventId: String,
            serviceId: String,
            isProvider: Bool,
            clientEventId: String,
            eventName: String
        )
    }
    
    @Published var navPath = NavigationPath()
    
    func navigate(to destination: Destination) {
        navPath.append(destination)
    }
    
    func navigateBack() {
        navPath.removeLast()
    }
    
    func navigateToRoot() {
        navPath.removeLast(navPath.count)
    }
}
