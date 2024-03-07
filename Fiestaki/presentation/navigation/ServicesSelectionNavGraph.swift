//
//  MainNavGraph.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/13/23.
//

import Foundation
import SwiftUI

final class ServicesSelectionNavGraph : ObservableObject {
        
    public enum Destination: Codable, Hashable {
        case onNavigateServicesCategories(ScreenInfo)
        case onNavigateServicesTypes(ScreenInfo)
        case onNavigateSubServices(ScreenInfo)
        case onNavigateAddServiceProvider1(ScreenInfo?, String?) // serviceId: String?
        case onNavigateAddServiceProvider2(ScreenInfo, ServiceProviderData, [String], [String], Bool) // images, videos, isEditing
        case onNavigateServices(ScreenInfo)
        case onNavigateServiceDetail(ScreenInfo)
        case onNavigatePhotoViewer([String])
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
