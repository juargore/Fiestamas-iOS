//
//  EventRepositoryImpl.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import FirebaseFirestore
import FirebaseAuth
import Foundation
import Combine

class EventRepositoryImpl: IEventRepository {
    
    private var firestore = Firestore.firestore()
    private var eventApi = EventApiImplementation()
    
    func getEventTypesList() -> AnyPublisher<[Event], Error> {
        let eventListRef = firestore.collection(Constants.eventTypes)
        return eventListRef.collectionListenerFlow(Event.self)
    }
    
    func getEventTypeById(id: String) -> AnyPublisher<Event?, Error> {
        let eventRef: DocumentReference = firestore.collection(Constants.eventTypes).document(id)
        return eventRef.documentListenerFlow(Event.self)
    }
    
    func createEventByClient(clientId: String, eventId: String, questions: FirstQuestions) -> AnyPublisher<Result<CreateEventResponse, Error>, Never> {
        return Future { promise in
            let eventRequest = CreateEventRequest(
                //id: nil,
                name: questions.festejadosNames,
                id_client: clientId,
                id_event_type: eventId,
                date: questions.date,
                location: questions.city,
                lat: String(questions.location?.lat ?? ""),
                lng: String(questions.location?.lng ?? ""),
                attendees: questions.numberOfGuests
            )
            self.eventApi.createNewEvent(eventRequest: eventRequest) { result in
                switch result {
                case .success(let response):
                    promise(.success(.success(response)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getClientEventsByClientEventId(id: String) -> AnyPublisher<[MyPartyEvent], Error> {
        let clientEventsCollection = firestore.collection(Constants.clientEvents)
        let query = clientEventsCollection
            .whereField(Constants.idClient, isEqualTo: id)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: Date.now))
        return clientEventsCollection.collectionListenerFlow(MyPartyEvent.self, query)
    }
    
    func getServicesEventByClientEventId(id: String) -> AnyPublisher<[MyPartyService], Error> {
        let serviceEventsCollection = firestore.collection(Constants.servicesEvent)
        let query = serviceEventsCollection.whereField(Constants.idClientEvent, isEqualTo: id)
        return serviceEventsCollection.collectionListenerFlow(MyPartyService.self, query)
    }
    
    func getServiceEventById(serviceEventId: String) -> AnyPublisher<MyPartyService?, Error> {
        let eventRef: DocumentReference = firestore.collection(Constants.servicesEvent).document(serviceEventId)
        return eventRef.documentListenerFlow(MyPartyService.self)
    }
    
    func getServicesEventByProviderId(id: String) -> AnyPublisher<[MyPartyService], Error> {
        let serviceEventsCollection = firestore.collection(Constants.servicesEvent)
        let query = serviceEventsCollection
            .whereField(Constants.idProvider, isEqualTo: id)
            .whereField("date", isGreaterThanOrEqualTo: Timestamp(date: Date.now))
        return serviceEventsCollection.collectionListenerFlow(MyPartyService.self, query)
    }
    
    func getMyPartyService(serviceEventId: String) -> AnyPublisher<MyPartyService?, Error> {
        let eventRef: DocumentReference = firestore.collection(Constants.servicesEvent).document(serviceEventId)
        return eventRef.documentListenerFlow(MyPartyService.self)
    }
    
    func addServiceToEvent(eventId: String, serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.eventApi.addServiceToExistingEvent(eventId: eventId, serviceId: serviceId) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
}
