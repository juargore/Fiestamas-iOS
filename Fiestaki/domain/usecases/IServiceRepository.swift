//
//  IServiceRepository.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import Combine

protocol IServiceRepository {
    func getServicesCategoriesList() -> AnyPublisher<[ServiceCategory], Error>

    func getServiceCategoryById(id: String) -> AnyPublisher<ServiceCategory?, Error>

    func getServiceCategoriesByEventId(id: String) -> AnyPublisher<[ServiceCategory], Error>

    func getEventsIdsByServiceCategoryId(id: String) -> AnyPublisher<[String], Error>

    func getServicesTypesByServiceCategoryId(id: String) -> AnyPublisher<[ServiceType], Error>

    func getServicesOptionsByServiceCategoryId(id: String) -> AnyPublisher<[Service], Error>

    func getServicesOptionsByServiceTypeId(id: String) -> AnyPublisher<[Service], Error>

    func getServicesOptionsBySubServiceId(id: String) -> AnyPublisher<[Service], Error>

    func getAttributesByServiceCategoryId(id: String) -> AnyPublisher<[Attribute], Error>

    func getAttributesByServiceTypeId(id: String) -> AnyPublisher<[Attribute], Error>

    func getAttributesBySubServiceId(id: String) -> AnyPublisher<[Attribute], Error>

    func getSubServicesByServiceTypeId(id: String) -> AnyPublisher<[SubService], Error>

    func getServiceDetails(id: String) -> AnyPublisher<Service?, Error>

    func getAttributeById(id: String) -> AnyPublisher<Attribute?, Error>

    func likeService(userId: String, serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func enableOrDisableService(serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func uploadMediaFile(uriFile: UriFile?) -> AnyPublisher<String, Error>

    func createServiceForProvider(request: AddServiceProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never>

    func updateServiceForProvider(serviceId: String, request: UpdateServiceProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never>

    func getServicesByProviderId(id: String) -> AnyPublisher<[Service], Error>

    func deleteServiceById(id: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func createNewQuote(id_service_event: String, isExpress: Bool) -> AnyPublisher<Result<CreateQuoteResponse, Error>, Never>

    func addItemToExistingQuote(id_service_event: String, id_quotation: String, items: [QuoteProductsInformation]) -> AnyPublisher<Result<Bool, Error>, Never>

    func deleteItemFromQuote(id_service_event: String, id_quotation: String, index: Int) -> AnyPublisher<Result<Bool, Error>, Never>

    func getQuoteByServiceEvent(serviceEventId: String) -> AnyPublisher<[GetQuoteResponse], Error>

    func createNewOffer(id_service_event: String, id_quotation: String, bid: Int, userId: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func acceptOffer(serviceEventId: String, quotationId: String, userId: String) -> AnyPublisher<Result<Bool, Error>, Never>
    
    func updateServiceStatus(serviceEventId: String, status: OptionsQuote) -> AnyPublisher<Result<Bool, Error>, Never>

    func addNotesToExistingQuote(serviceEventId: String, quotationId: String, notes: String?, noteBook: String?, notesClient: String?, notesProvider: String?) -> AnyPublisher<Result<Bool, Error>, Never>

    func updateExpressQuote(serviceEventId: String, quotationId: String, notes: String?, notesClient: String?, notesProvider: String?) -> AnyPublisher<Result<Bool, Error>, Never>

    func requestQuoteFromClientToProvider(serviceEventId: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func requestEditQuoteFromProviderToClient(serviceEventId: String, quoteId: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func acceptEditQuoteFromClientToProvider(serviceEventId: String, quoteId: String, messageId: String) -> AnyPublisher<Result<Bool, Error>, Never>

    func declineEditQuoteFromClientToProvider(serviceEventId: String, quoteId: String, messageId: String) -> AnyPublisher<Result<Bool, Error>, Never>
}
