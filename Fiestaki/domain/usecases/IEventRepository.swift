//
//  IEventRepository.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

protocol IEventRepository {
    
    func getEventTypesList() -> AnyPublisher<[Event], Error>
    
    func getEventTypeById(id: String) -> AnyPublisher<Event?, Error>
    
    func createEventByClient(clientId: String, eventId: String, questions: FirstQuestions) -> AnyPublisher<Result<CreateEventResponse, Error>, Never>
    
    func getClientEventsByClientEventId(id: String) -> AnyPublisher<[MyPartyEvent], Error>
    
    func getServicesEventByClientEventId(id: String) -> AnyPublisher<[MyPartyService], Error>
    
    func getServiceEventById(serviceEventId: String) -> AnyPublisher<MyPartyService?, Error>
    
    func getServicesEventByProviderId(id: String) -> AnyPublisher<[MyPartyService], Error>
    
    func getMyPartyService(serviceEventId: String) -> AnyPublisher<MyPartyService?, Error>
    
    func addServiceToEvent(eventId: String, serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never>
}
