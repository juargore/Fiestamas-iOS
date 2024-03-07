//
//  ServicesCategoriesViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/10/23.
//

import Foundation
import Combine
import SwiftUI

final class ServicesCategoriesViewModel: ObservableObject {
    
    private let eventUseCase = EventUseCase()
    private let serviceUseCase = ServiceUseCase()
    private var disposables = Set<AnyCancellable>()
 
    @Published var eventsByService: [Event] = []
    @Published var servicesByEvent: [ServiceCategory] = []
    
    //@State var alreadyCreatedEvent = false
    
    func getEventId(screenInfo: ScreenInfo) -> String {
        if screenInfo.role == Role.Provider {
            return "b26WVIm9RcEvXtqfiYDe"
        } else {
            return screenInfo.event?.id ?? ""
        }
    }
    
    func getServicesByEventId(eventId: String) {
        serviceUseCase
            .getServiceCategoriesByEventId(id: eventId)
            .sink { _ in } receiveValue: { list in
                DispatchQueue.main.async {
                    self.servicesByEvent = list
                }
            }.store(in: &disposables)
    }
    
    func getServicesCountByCategoryId(
        serviceCategoryId: String,
        onCompleted: @escaping (Int) -> Void
    ) {
        serviceUseCase
            .getServicesTypesByServiceCategoryId(id: serviceCategoryId)
            .sink { _ in } receiveValue: { services in
                onCompleted(services.count)
            }.store(in: &disposables)
    }
    
    func getEventsByServiceCategoryId(serviceId: String) {
        serviceUseCase
            .getEventsByServiceCategoryId(id: serviceId)
            .sink { _ in } receiveValue: { list in
                self.eventsByService = list
            }.store(in: &disposables)
    }
    
    func createEventByClient(
        clientId: String,
        eventId: String,
        questions: FirstQuestions,
        onEventCreated: @escaping (CreateEventResponse?) -> Void
    ) {
        //if !alreadyCreatedEvent {
            //alreadyCreatedEvent = true
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
        //}
    }
    
    func getNewScreenInfo(
        screenInfo: ScreenInfo,
        serviceCategory: ServiceCategory,
        questions: FirstQuestions?,
        clientEventId: String?
    ) -> ScreenInfo {
        return ScreenInfo(
            role: screenInfo.role,
            startedScreen: screenInfo.startedScreen,
            prevScreen: Screen.ServiceCategories,
            event: screenInfo.event,
            questions: questions,
            serviceCategory: serviceCategory,
            clientEventId: clientEventId
        )
    }
}
