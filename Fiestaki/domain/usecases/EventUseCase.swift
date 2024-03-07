//
//  EventUseCase.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

class EventUseCase {
    
    private let eventRepository = EventRepositoryImpl()
    private var disposables = Set<AnyCancellable>()
    
    func getEventTypesList() -> AnyPublisher<[Event], Error> {
        return eventRepository.getEventTypesList()
    }
    
    func getEventTypeById(id: String) -> AnyPublisher<Event?, Error> {
        return eventRepository.getEventTypeById(id: id)
    }
    
    func createEventByClient(clientId: String, eventId: String, questions: FirstQuestions) -> AnyPublisher<Result<CreateEventResponse, Error>, Never> {
        return eventRepository.createEventByClient(clientId: clientId, eventId: eventId, questions: questions)
    }
    
    func addServiceToEvent(eventId: String, serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return eventRepository.addServiceToEvent(eventId: eventId, serviceId: serviceId)
    }
    
    func getMyPartyEventsWithServices(id: String) -> AnyPublisher<[MyPartyEventWithServices], Error> {
        return Future { promise in
            self.eventRepository
                .getClientEventsByClientEventId(id: id)
                .sink { _ in } receiveValue: { (list: [MyPartyEvent]) -> Void in
                    var mList = [MyPartyEventWithServices]()
                    for i in list {
                        mList.append(MyPartyEventWithServices(event: i, servicesEvents: nil))
                    }
                    
                    mList.indices.forEach { index in
                        let event = mList[index].event
                        if event != nil {
                            self.getServicesEventByEventId(eventId: (event?.id!)!) { servicesList in
                                mList[index].servicesEvents = servicesList
                                
                                // calculate pending days until given date
                                if event!.date != nil {
                                    let eventDate = convertStringToDate(event!.date!)
                                    let pendingDays = daysUntilDate(eventDate)
                                    mList[index].event?.pendingDays = pendingDays
                                }
                                
                                // calculate sum of costs for every service to set in event
                                var sumOfCosts = 0
                                mList[index].servicesEvents?.forEach { myService in
                                    sumOfCosts += myService.price ?? 0
                                }
                                mList[index].event?.finalCost = sumOfCosts
                                
                                // return data when all events have their services
                                if index == mList.indices.last {
                                    promise(.success(mList))
                                }
                            }
                        }
                    }
                }
                .store(in: &self.disposables)
        }.eraseToAnyPublisher()
    }
    
    private func getServicesEventByEventId(eventId: String, onFinish: @escaping ([MyPartyService]) -> Void) {
        eventRepository
            .getServicesEventByClientEventId(id: eventId)
            .first()
            .sink { _ in } receiveValue: { (list: [MyPartyService]) -> Void in
                onFinish(list)
            }.store(in: &disposables)
    }
    
    func getMyPartyServicesByProvider(id: String) -> AnyPublisher<[MyPartyService], Error> {
        return eventRepository.getServicesEventByProviderId(id: id)
    }
    
    func getMyPartyService(serviceEventId: String) -> AnyPublisher<MyPartyService?, Error> {
        return eventRepository.getMyPartyService(serviceEventId: serviceEventId)
    }
}
