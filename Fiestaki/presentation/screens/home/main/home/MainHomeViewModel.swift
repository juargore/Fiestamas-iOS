//
//  HomeViewModel.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 05/05/23.
//

import Firebase
import Combine
import SwiftUI
import CoreLocation

enum FilterType {
    case serviceCategory
    case serviceType
    case subServiceType
}

struct IdFilter {
    var id: String
    var type: FilterType
}

final class MainHomeViewModel: ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    
    @Published var eventUseCase = EventUseCase()
    @Published var serviceUseCase = ServiceUseCase()
    @Published var appStorageManager = AppStorageManager()
    @Published var eventTypes: [Event] = []
    @Published var serviceCategories: [ServiceCategory] = []
    
    func shouldRedirectToMyParty() -> Bool {
        let firstTime = appStorageManager
            .getValue(model: Bool.self, for: StorageKeys.appFirstLaunch)
        return firstTime ?? false
    }
    
    func getServiceCategories() {
        serviceUseCase
            .getServicesCategoriesList()
            .sink { _ in } receiveValue: { list in
                self.serviceCategories = list
            }.store(in: &disposables)
    }
    
    func getEventTypes() {
        eventUseCase
            .getEventTypesList()
            .sink { _ in } receiveValue: { list in
                let listWithoutPhantom = list.filter { $0.name != "Fantasma" }
                self.eventTypes = listWithoutPhantom.sorted(by: { $0.index! > $1.index! }).reversed()
            }.store(in: &disposables)
    }
    
}
