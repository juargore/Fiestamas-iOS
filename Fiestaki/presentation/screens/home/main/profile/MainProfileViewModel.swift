//
//  MainProfileViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 12/29/23.
//

import Foundation
import Combine
import SwiftUI

final class MainProfileViewModel: ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    
    @Published var eventUseCase = EventUseCase()
    
    @Published var totalServices = 0
    
    func getTotalServicesByProvider(providerId: String) {
        eventUseCase
            .getMyPartyServicesByProvider(id: providerId)
            .sink { _ in } receiveValue: { list in
                self.totalServices = list.count
            }.store(in: &disposables)
    }
}
