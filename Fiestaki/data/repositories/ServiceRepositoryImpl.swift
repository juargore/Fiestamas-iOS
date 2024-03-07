//
//  ServiceRepositoryImpl.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/8/23.
//

import FirebaseFirestore
import FirebaseStorage
import FirebaseAuth
import Foundation
import Combine

class ServiceRepositoryImpl: IServiceRepository {
    
    //private var firestore = Firestore.firestore()
    private var serviceApi = ServiceApiImplementation()
    
    private var firestore: Firestore
    
    init(firestore: Firestore = Firestore.firestore()) {
        //let settings = FirestoreSettings()
        //settings.isPersistenceEnabled = false
        self.firestore = firestore
        //self.firestore.settings = settings
    }
    
    func getServicesCategoriesList() -> AnyPublisher<[ServiceCategory], Error> {
        let eventListRef = firestore.collection(Constants.serviceCategories)
        return eventListRef.collectionListenerFlow(ServiceCategory.self)
    }
    
    func getServiceCategoryById(id: String) -> AnyPublisher<ServiceCategory?, Error> {
        let eventRef: DocumentReference = firestore.collection(Constants.serviceCategories).document(id)
        return eventRef.documentListenerFlow(ServiceCategory.self)
    }
    
    func getServiceCategoriesByEventId(id: String) -> AnyPublisher<[ServiceCategory], Error> {
        let serviceCategoriesCollection = firestore.collection(Constants.serviceCategories)
        let query = serviceCategoriesCollection.whereField(Constants.eventsTypes, arrayContains: id)
        return serviceCategoriesCollection.collectionListenerFlow(ServiceCategory.self, query)
    }
    
    func getEventsIdsByServiceCategoryId(id: String) -> AnyPublisher<[String], Error> {
        let eventRef: DocumentReference = firestore.collection(Constants.serviceCategories).document(id)
        return eventRef.documentListenerFlow(ServiceCategory.self)
            .map {
                return $0?.events_types ?? []
            }.eraseToAnyPublisher()
    }
    
    func getServicesTypesByServiceCategoryId(id: String) -> AnyPublisher<[ServiceType], Error> {
        let serviceTypesCollection = firestore.collection(Constants.serviceTypes)
        let query = serviceTypesCollection.whereField(Constants.idServiceCategory, isEqualTo: id)
        return serviceTypesCollection.collectionListenerFlow(ServiceType.self, query)
    }
    
    func getServicesOptionsByServiceCategoryId(id: String) -> AnyPublisher<[Service], Error> {
        let serviceTypesCollection = firestore.collection(Constants.services)
        let query = serviceTypesCollection
            .whereField(Constants.idServiceCategory, isEqualTo: id)
            .whereField(Constants.isDeleted, isEqualTo: false)
        return serviceTypesCollection.collectionListenerFlow(Service.self, query)
    }
    
    func getServicesOptionsByServiceTypeId(id: String) -> AnyPublisher<[Service], Error> {
        let serviceTypesCollection = firestore.collection(Constants.services)
        let query = serviceTypesCollection
            .whereField(Constants.idServiceType, isEqualTo: id)
            .whereField(Constants.isDeleted, isEqualTo: false)
        return serviceTypesCollection.collectionListenerFlow(Service.self, query)
    }
    
    func getServicesOptionsBySubServiceId(id: String) -> AnyPublisher<[Service], Error> {
        let serviceTypesCollection = firestore.collection(Constants.services)
        let query = serviceTypesCollection
            .whereField(Constants.idSubServiceType, isEqualTo: id)
            .whereField(Constants.isDeleted, isEqualTo: false)
        return serviceTypesCollection.collectionListenerFlow(Service.self, query)
    }
    
    func getAttributesByServiceCategoryId(id: String) -> AnyPublisher<[Attribute], Error> {
        let serviceTypesCollection = firestore.collection(Constants.attributes)
        let query = serviceTypesCollection.whereField(Constants.idServiceCategory, isEqualTo: id)
        return serviceTypesCollection.collectionListenerFlow(Attribute.self, query)
    }
    
    func getAttributesByServiceTypeId(id: String) -> AnyPublisher<[Attribute], Error> {
        let serviceTypesCollection = firestore.collection(Constants.attributes)
        let query = serviceTypesCollection.whereField(Constants.idServiceType, isEqualTo: id)
        return serviceTypesCollection.collectionListenerFlow(Attribute.self, query)
    }
    
    func getAttributesBySubServiceId(id: String) -> AnyPublisher<[Attribute], Error> {
        let serviceTypesCollection = firestore.collection(Constants.attributes)
        let query = serviceTypesCollection.whereField(Constants.idSubServiceType, isEqualTo: id)
        return serviceTypesCollection.collectionListenerFlow(Attribute.self, query)
    }
    
    func getSubServicesByServiceTypeId(id: String) -> AnyPublisher<[SubService], Error> {
        let serviceTypesCollection = firestore.collection(Constants.subServiceTypes)
        let query = serviceTypesCollection.whereField(Constants.idServiceType, isEqualTo: id)
        return serviceTypesCollection.collectionListenerFlow(SubService.self, query)
    }
    
    func getServiceDetails(id: String) -> AnyPublisher<Service?, Error> {
        let eventRef: DocumentReference = firestore.collection(Constants.services).document(id)
        return eventRef.documentListenerFlow(Service.self)
    }
    
    func getAttributeById(id: String) -> AnyPublisher<Attribute?, Error> {
        let eventRef: DocumentReference = firestore.collection(Constants.attributes).document(id)
        return eventRef.documentListenerFlow(Attribute.self)
    }
    
    func likeService(userId: String, serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in 
            self.serviceApi.likeService(userId: userId, serviceId: serviceId) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func enableOrDisableService(serviceId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.enableOrDisableService(idService: serviceId) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func uploadMediaFile(uriFile: UriFile?) -> AnyPublisher<String, Error> {
        return Future { promise in
            if uriFile == nil {
                let error = NSError(domain: "Error", code: 500, userInfo: [NSLocalizedDescriptionKey: "UriFile is nil"])
                promise(.failure(error))
            } else {
                let storage = Storage.storage()
                let storageRef = storage.reference()
                let testFolderRef = storageRef.child("test")
                if let fileName = uriFile?.fileName, let uri = uriFile?.uri {
                    let imageRef = testFolderRef.child(fileName)
                    let uploadTask = imageRef.putFile(from: uri)
                    uploadTask.observe(.success) { snapshot in
                        imageRef.downloadURL { (url, error) in
                            if let downloadURL = url {
                                promise(.success(downloadURL.absoluteString))
                            } else if let error = error {
                                promise(.failure(error))
                            }
                        }
                    }
                }
            }
        }
        .eraseToAnyPublisher()
    }
    
    func createServiceForProvider(request: AddServiceProviderRequest) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.createService(request: request) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateServiceForProvider(serviceId: String, request: UpdateServiceProviderRequest)
    -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.updateService(idService: serviceId, request: request) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getServicesByProviderId(id: String) -> AnyPublisher<[Service], Error> {
        let servicesCollection = firestore.collection(Constants.services)
        let query = servicesCollection
            .whereField(Constants.idProvider, isEqualTo: id)
            .whereField(Constants.isDeleted, isEqualTo: false)
        return servicesCollection.collectionListenerFlow(Service.self, query)
    }
    
    func deleteServiceById(id: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.deleteService(serviceId: id) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func createNewQuote(id_service_event: String, isExpress: Bool) -> AnyPublisher<Result<CreateQuoteResponse, Error>, Never> {
        return Future { promise in
            if isExpress {
                let request = ItemsExpressQuoteRequest(type: "EXPRESS")
                self.serviceApi.createNewExpressQuote(idServiceEvent: id_service_event, request: request) { result in
                    switch result {
                    case .success(let response):
                        promise(.success(.success(response)))
                    case .failure(let error):
                        promise(.success(.failure(error)))
                    }
                }
            } else {
                self.serviceApi.createNewClassicQuote(idServiceEvent: id_service_event) { result in
                    switch result {
                    case .success(let response):
                        promise(.success(.success(response)))
                    case .failure(let error):
                        promise(.success(.failure(error)))
                    }
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func addItemToExistingQuote(id_service_event: String, id_quotation: String, items: [QuoteProductsInformation])
    -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            let elements: [ItemQuoteRequest] = items.map { $0.toItemQuoteRequest() }
            let request = ItemsQuoteRequest(elements: elements)
            self.serviceApi.addItemsToExistingQuote(
                idServiceEvent: id_service_event,
                idQuotation: id_quotation,
                request: request
            ) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func deleteItemFromQuote(id_service_event: String, id_quotation: String, index: Int)
    -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.deleteItemsFromExistingQuote(
                idServiceEvent: id_service_event,
                idQuotation: id_quotation,
                index: index
            ) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func getQuoteByServiceEvent(serviceEventId: String) -> AnyPublisher<[GetQuoteResponse], Error> {
        let serviceTypesCollection = firestore.collection(Constants.quotations)
        let query = serviceTypesCollection.whereField(Constants.idServiceEvent, isEqualTo: serviceEventId)
        return serviceTypesCollection.collectionListenerFlow(GetQuoteResponse.self, query)
    }
    
    func createNewOffer(id_service_event: String, id_quotation: String, bid: Int, userId: String)
    -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            let request = ItemBidOfferRequest(bid: bid, id_user: userId)
            self.serviceApi.createNewOffer(idServiceEvent: id_service_event, idQuotation: id_quotation, request: request) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func acceptOffer(serviceEventId: String, quotationId: String, userId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            let request = ItemBidAcceptedRequest(status: "ACCEPTED", id_user: userId)
            self.serviceApi.acceptOffer(idServiceEvent: serviceEventId, idQuotation: quotationId, request: request) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func updateServiceStatus(serviceEventId: String, status: OptionsQuote) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            let request = ItemUpdateStatusRequest(status: status.toStringStatus())
            self.serviceApi.updateServiceStatus(idServiceEvent: serviceEventId, request: request) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func addNotesToExistingQuote(serviceEventId: String, quotationId: String, notes: String?, noteBook: String?, notesClient: String?, notesProvider: String?) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            let request = ItemAddNotesToQuoteRequest(
                notes: notes ?? " ",
                deposit: 0,
                noteBook_client : notesClient ?? " ",
                noteBook_provider : notesProvider ?? " "
            )
            self.serviceApi.addNotesToExistingQuote(
                idServiceEvent: serviceEventId,
                idQuotation: quotationId,
                request: request
            ) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
            
        }.eraseToAnyPublisher()
    }
    
    func updateExpressQuote(serviceEventId: String, quotationId: String, notes: String?, notesClient: String?, notesProvider: String?) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            let request = ItemAddNotesToQuoteRequest(
                notes: notes ?? " ",
                deposit: 0,
                noteBook_client: notesClient ?? " ",
                noteBook_provider: notesProvider ?? " "
            )
            self.serviceApi.updateExpressQuote(idServiceEvent: serviceEventId, idQuotation: quotationId, request: request) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func requestQuoteFromClientToProvider(serviceEventId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.requestQuotation(idServiceEvent: serviceEventId) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func requestEditQuoteFromProviderToClient(serviceEventId: String, quoteId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.requestEditQuote(idServiceEvent: serviceEventId, idQuotation: quoteId) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func acceptEditQuoteFromClientToProvider(serviceEventId: String, quoteId: String, messageId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.approveRequestEditQuote(idServiceEvent: serviceEventId, idQuotation: quoteId, idMessage: messageId) { result in
                switch result {
                case .success(_):
                    promise(.success(.success(true)))
                case .failure(let error):
                    promise(.success(.failure(error)))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    func declineEditQuoteFromClientToProvider(serviceEventId: String, quoteId: String, messageId: String) -> AnyPublisher<Result<Bool, Error>, Never> {
        return Future { promise in
            self.serviceApi.declineRequestEditQuote(idServiceEvent: serviceEventId, idQuotation: quoteId, idMessage: messageId) { result in
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


extension OptionsQuote {
    func toStringStatus() -> String {
        switch (self) {
        case OptionsQuote.Hired: return "CONTACTED"
        case OptionsQuote.Pending: return "PENDING"
        case OptionsQuote.Cancel: return "CANCELLED"
        }
    }
}
