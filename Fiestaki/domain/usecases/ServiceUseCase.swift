//
//  ServiceUseCase.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

class ServiceUseCase {
    
    private let serviceRepository = ServiceRepositoryImpl()
    private let eventRepository = EventRepositoryImpl()
    private var disposables = Set<AnyCancellable>()
    typealias Pair = (firstList: [String], secondList: [String])
    
    func getServicesCategoriesList() -> AnyPublisher<[ServiceCategory], Error> {
        return serviceRepository.getServicesCategoriesList()
    }
    
    func getServiceCategoryById(id: String) -> AnyPublisher<ServiceCategory?, Error> {
        return serviceRepository.getServiceCategoryById(id: id)
    }

    func getServiceCategoriesByEventId(id: String) -> AnyPublisher<[ServiceCategory], Error> {
        return serviceRepository.getServiceCategoriesByEventId(id: id)
    }
    
    func getEventsByServiceCategoryId(id: String) -> AnyPublisher<[Event], Error> {
        return Future { promise in
            self.serviceRepository
                .getEventsIdsByServiceCategoryId(id: id)
                .sink { _ in } receiveValue: { eventsIds in
                    self.getEventsTypesByIds(eventsIds) { eventList in
                        promise(.success(eventList))
                    }
                }.store(in: &self.disposables)
        }.eraseToAnyPublisher()
    }
    
    private func getEventsTypesByIds(_ eventIds: [String], onFinished: @escaping ([Event]) -> Void) {
        var eventList = [Event]()
        let publishers = eventIds.map { id in
            return self.eventRepository.getEventTypeById(id: id)
                .first()
                .compactMap { $0 } // delete nil values
                .map { event in
                    return event
                }
        }
        Publishers.MergeMany(publishers)
            .collect()
            .sink { completion in
                switch completion {
                case .finished:
                    onFinished(eventList)
                case .failure(let error):
                    debugPrint("Error: ", error.localizedDescription)
                }
            } receiveValue: { events in
                eventList.append(contentsOf: events)
            }.store(in: &self.disposables)
    }
    
    func getServicesTypesByServiceCategoryId(id: String) -> AnyPublisher<[ServiceType], Error> {
        return serviceRepository.getServicesTypesByServiceCategoryId(id: id)
    }

    func getServicesOptionsByServiceCategoryId(id: String) -> AnyPublisher<[Service], Error> {
        return serviceRepository.getServicesOptionsByServiceCategoryId(id: id)
    }

    func getServicesOptionsByServiceTypeId(id: String) -> AnyPublisher<[Service], Error> {
        return serviceRepository.getServicesOptionsByServiceTypeId(id: id)
    }

    func getServicesOptionsBySubServiceId(id: String) -> AnyPublisher<[Service], Error> {
        return serviceRepository.getServicesOptionsBySubServiceId(id: id)
    }

    func getAttributesByServiceCategoryId(id: String) -> AnyPublisher<[Attribute], Error> {
        return serviceRepository.getAttributesByServiceCategoryId(id: id)
    }

    func getAttributesByServiceTypeId(id: String) -> AnyPublisher<[Attribute], Error> {
        return serviceRepository.getAttributesByServiceTypeId(id: id)
    }

    func getAttributesBySubServiceId(id: String) -> AnyPublisher<[Attribute], Error> {
        return serviceRepository.getAttributesBySubServiceId(id: id)
    }

    func getSubServicesByServiceTypeId(id: String) -> AnyPublisher<[SubService], Error> {
        return serviceRepository.getSubServicesByServiceTypeId(id: id)
    }

    func getServiceDetails(id: String) -> AnyPublisher<Service?, Error> {
        return serviceRepository.getServiceDetails(id: id)
    }
    
    func getAttributesByIds(ids: [String]) -> AnyPublisher<[Attribute], Error> {
        return Future { promise in
            var attributes = [Attribute]()
            let publishers = ids.map { id in
                return self.serviceRepository.getAttributeById(id: id)
                    .first()
                    .compactMap { $0 }
                    .map { attribute in
                        return attribute
                    }
            }
            Publishers.MergeMany(publishers)
                .collect()
                .sink { completion in
                    switch completion {
                    case .finished:
                        promise(.success(attributes))
                    case .failure(let error):
                        debugPrint("Error: ", error.localizedDescription)
                    }
                } receiveValue: { attribute in
                    attributes.append(contentsOf: attribute)
                }.store(in: &self.disposables)
        }.eraseToAnyPublisher()
    }

    func likeService(userId: String, serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.likeService(userId: userId, serviceId: serviceId)
    }

    func enableOrDisableService(serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.enableOrDisableService(serviceId: serviceId)
    }

    func uploadMediaFiles(images: [UriFile]?, videos: [UriFile]?) -> AnyPublisher<Pair, Error> {
        return Future { promise in
            var imagesUrl = [String]()
            var videosUrl = [String]()
            if images != nil {
                for uri in images! {
                    self.serviceRepository
                        .uploadMediaFile(uriFile: uri)
                        .sink { complete in
                            switch complete {
                            case .finished:
                                promise(.success(Pair(imagesUrl, videosUrl)))
                            case.failure(let error):
                                debugPrint("Error: ", error.localizedDescription)
                            }
                        } receiveValue: { response in
                            if !response.isEmpty {
                                imagesUrl.append(response)
                            }
                        }.store(in: &self.disposables)
                }
            }
            if videos != nil {
                for uri in videos! {
                    self.serviceRepository
                        .uploadMediaFile(uriFile: uri)
                        .sink { _ in } receiveValue: { response in
                            if !response.isEmpty {
                                videosUrl.append(response)
                            }
                        }.store(in: &self.disposables)
                }
            }
        }.eraseToAnyPublisher()
    }

    func createServiceForProvider(request: AddServiceProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.createServiceForProvider(request: request)
    }

    func updateServiceForProvider(serviceId: String, request: UpdateServiceProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.updateServiceForProvider(serviceId: serviceId, request: request)
    }

    func getServicesByProviderId(id: String) -> AnyPublisher<[Service], Error> {
        return serviceRepository.getServicesByProviderId(id: id)
    }

    func deleteServiceById(id: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.deleteServiceById(id: id)
    }
    
    func getReviewsByServiceId(id: String) -> AnyPublisher<[UserReview], Error> {
        let reviews = [
            UserReview(
                id: "1",
                name: "Bill Gates",
                photo: "https://w7.pngwing.com/pngs/471/773/png-transparent-bill-gates-bill-gates-seattle-microsoft-berkshire-hathaway-chairman-bill-gates-company-people-recruiter-thumbnail.png",
                message: "Buen servicio y atención"
            ),
            UserReview(
                id: "2",
                name: "John Doe",
                photo: "https://www.freecodecamp.org/news/content/images/2022/06/hrishikesh.jpg",
                message: "Lorem ipsum dolor sit amet, consectetur adipiscing elit, sed do eiusmod tempor incididunt ut labore et dolore magna aliqua."
            )
        ]
        return Future { promise in
            promise(.success(reviews))
        }.eraseToAnyPublisher()
    }

    func createNewQuote(
        id_service_event: String,
        isExpress: Bool,
        elements: [QuoteProductsInformation]
    ) -> AnyPublisher<String, Error> {
        return Future { promise in
            self.serviceRepository
                .createNewQuote(id_service_event: id_service_event, isExpress: isExpress)
                .sink { _ in } receiveValue: { responseCreate in
                    do {
                        let quoteId = try responseCreate.get().id
                        self.addItemToExistingQuote(
                            idServiceEvent: id_service_event,
                            idQuotation: quoteId,
                            items: elements,
                            onFinished: {
                                promise(.success(quoteId))
                            })
                    } catch {
                        promise(.failure(error))
                    }
                }.store(in: &self.disposables)
        }.eraseToAnyPublisher()
    }
    
    private func addItemToExistingQuote(
        idServiceEvent: String,
        idQuotation: String,
        items: [QuoteProductsInformation],
        onFinished: @escaping () -> Void
    ) {
        serviceRepository
            .addItemToExistingQuote(id_service_event: idServiceEvent, id_quotation: idQuotation, items: items)
            .sink { _ in } receiveValue: { result in
                onFinished()
            }.store(in: &disposables)
    }
    
    func updateElementsInQuote(
            id_service_event: String,
            id_quotation: String,
            sizeOldElements: Int,
            newElements: [QuoteProductsInformation]
    ) -> AnyPublisher<Bool, Error> {
        return Future { promise in
            for i in 0...sizeOldElements {
                self.serviceRepository
                    .deleteItemFromQuote(id_service_event: id_service_event, id_quotation: id_quotation, index: i)
                    .sink { _ in }
                    .store(in: &self.disposables)
            }
            self.serviceRepository
                .addItemToExistingQuote(id_service_event: id_service_event, id_quotation: id_quotation, items: newElements)
                .sink { _ in } receiveValue: { response in
                    promise(.success(true))
                }.store(in: &self.disposables)
        }.eraseToAnyPublisher()
    }

    func getQuoteByServiceEvent(serviceEventId: String) -> AnyPublisher<[GetQuoteResponse], Error> {
        return serviceRepository.getQuoteByServiceEvent(serviceEventId: serviceEventId)
    }
    
    func createNewOffer(id_service_event: String, id_quotation: String, bid: Int,userId: String)
    -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository
            .createNewOffer(id_service_event: id_service_event, id_quotation: id_quotation, bid: bid, userId: userId)
    }
    
    func acceptOffer(serviceEventId: String, quotationId: String, userId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.acceptOffer(serviceEventId: serviceEventId, quotationId: quotationId, userId: userId)
    }

    func updateServiceStatus(serviceEventId: String, status: OptionsQuote) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.updateServiceStatus(serviceEventId: serviceEventId, status: status)
    }
    
    func addNotesToExistingQuote(
            serviceEventId: String,
            quotationId: String,
            providerNotes: String?,
            noteBook: String?,
            notesClient: String?,
            notesProvider: String?
    ) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.addNotesToExistingQuote(serviceEventId: serviceEventId, quotationId: quotationId, notes: providerNotes, noteBook: noteBook, notesClient: notesClient, notesProvider: notesProvider)
    }
    
    func updateExpressQuote(
        serviceEventId: String,
        quotationId: String,
        providerNotes: String?,
        notesClient: String?,
        notesProvider: String?
    ) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.updateExpressQuote(serviceEventId: serviceEventId, quotationId: quotationId, notes: providerNotes, notesClient: notesClient, notesProvider: notesProvider)
    }
    
    func requestQuoteFromClientToProvider(serviceEventId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.requestQuoteFromClientToProvider(serviceEventId: serviceEventId)
    }

    func requestEditQuoteFromProviderToClient(serviceEventId: String, quoteId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return serviceRepository.requestEditQuoteFromProviderToClient(serviceEventId: serviceEventId, quoteId: quoteId)
    }

    func acceptEditQuoteFromClientToProvider(serviceEventId: String, messageId: String) -> AnyPublisher<Bool, Error> {
        return Future { promise in
            self.getQuoteByServiceEvent(serviceEventId: serviceEventId)
                .sink { _ in } receiveValue: { quote in
                    self.acceptOrDeclineEditQuote(
                        accepted: true,
                        serviceEventId: serviceEventId,
                        quoteId: quote.first?.id ?? "",
                        messageId: messageId,
                        onFinished: {
                            promise(.success(true))
                        }
                    )
                }.store(in: &self.disposables)
        }.eraseToAnyPublisher()
    }
    
    private func acceptOrDeclineEditQuote(
        accepted: Bool,
        serviceEventId: String,
        quoteId: String,
        messageId: String,
        onFinished: @escaping () -> Void
    ) {
        if accepted {
            self.serviceRepository
                .acceptEditQuoteFromClientToProvider(serviceEventId: serviceEventId, quoteId: quoteId, messageId: messageId)
                .sink { _ in onFinished() }
                .store(in: &self.disposables)
        } else {
            self.serviceRepository
                .declineEditQuoteFromClientToProvider(serviceEventId: serviceEventId, quoteId: quoteId, messageId: messageId)
                .sink { _ in onFinished() }
                .store(in: &self.disposables)
        }
    }

    func declineEditQuoteFromClientToProvider(serviceEventId: String, messageId: String) -> AnyPublisher<Bool, Error> {
        return Future { promise in
            self.getQuoteByServiceEvent(serviceEventId: serviceEventId)
                .sink { _ in } receiveValue: { quote in
                    self.acceptOrDeclineEditQuote(
                        accepted: false,
                        serviceEventId: serviceEventId,
                        quoteId: quote.first?.id ?? "",
                        messageId: messageId,
                        onFinished: {
                            promise(.success(true))
                        }
                    )
                }.store(in: &self.disposables)
        }.eraseToAnyPublisher()
    }
}

enum OptionsQuote {
    case Hired
    case Pending
    case Cancel
}
