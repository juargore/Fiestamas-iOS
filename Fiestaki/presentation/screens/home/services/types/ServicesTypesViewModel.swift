//
//  ServicesTypesViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/13/23.
//

import Foundation
import SwiftUI
import Combine

final class ServicesTypesViewModel: ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    
    private let eventUseCase = EventUseCase()
    private let serviceUseCase = ServiceUseCase()
    
    @Published var servicesByCategory: [ServiceType] = []
    
    @State var alreadyCreatedEvent = false
    
    func getServicesByCategoryId(serviceCategoryId: String) {
        serviceUseCase
            .getServicesTypesByServiceCategoryId(id: serviceCategoryId)
            .sink { _ in } receiveValue: { services in
                self.servicesByCategory = services
            }.store(in: &disposables)
    }
    
    func getSubServicesCountByServiceTypeId(
        serviceTypeId: String,
        onCompleted: @escaping (Int) -> Void
    ) {
        serviceUseCase
            .getSubServicesByServiceTypeId(id: serviceTypeId)
            .sink { _ in} receiveValue: { subServices in
                onCompleted(subServices.count)
            }.store(in: &disposables)
    }
    
    func createEventByClient(
        clientId: String,
        eventId: String,
        questions: FirstQuestions,
        onEventCreated: @escaping (CreateEventResponse?) -> Void
    ) {
        if !alreadyCreatedEvent {
            alreadyCreatedEvent = true
            eventUseCase
                .createEventByClient(clientId: clientId, eventId: eventId, questions: questions)
                .sink { _ in } receiveValue: { response in
                    switch response {
                    case .success(let createEventResponse):
                        onEventCreated(createEventResponse)
                    case .failure(_):
                        onEventCreated(nil)
                    }
                }.store(in: &disposables)
        }
    }
    
    func getNewScreenInfo(
        screenInfo: ScreenInfo,
        serviceType: ServiceType?,
        subServiceType: SubService?
    ) -> ScreenInfo {
        return ScreenInfo(
            role: screenInfo.role,
            startedScreen: screenInfo.startedScreen,
            prevScreen: Screen.ServiceTypes,
            event: screenInfo.event,
            questions: screenInfo.questions,
            serviceCategory: screenInfo.serviceCategory,
            clientEventId: screenInfo.clientEventId,
            serviceType: serviceType,
            subService: subServiceType
        )
    }
}
