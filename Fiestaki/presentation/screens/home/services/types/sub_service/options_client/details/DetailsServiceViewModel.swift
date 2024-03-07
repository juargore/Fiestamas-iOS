//
//  DetailsServiceViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/23/23.
//

import Foundation
import SwiftUI
import Combine

final class DetailsServiceViewModel: ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    
    private let serviceUseCase = ServiceUseCase()
    private let eventUseCase = EventUseCase()
    
    @Published var service: Service? = nil
    @Published var attributes: [Attribute] = []
    @Published var reviews: [UserReview] = []
    
    func getServiceDetails(serviceId: String, getAlsoAttributes: Bool = true, onFinished: @escaping (Service?) -> Void) {
        serviceUseCase
            .getServiceDetails(id: serviceId)
            .sink { _ in } receiveValue: { mService in
                self.service = mService
                onFinished(self.service)
                
                if getAlsoAttributes {
                    self.getAttributes(ids: self.service?.attributes ?? [])
                    self.getReviewsByServiceId(id: "")
                }
            }.store(in: &disposables)
    }
    
    func getAttributes(ids: [String]) {
        if !ids.isEmpty {
            serviceUseCase
                .getAttributesByIds(ids: ids)
                .sink { _ in } receiveValue: { mAttributes in
                    self.attributes = mAttributes
                }.store(in: &disposables)
        }
    }
    
    func getReviewsByServiceId(id: String) {
        serviceUseCase
            .getReviewsByServiceId(id: id)
            .sink { _ in } receiveValue: { mReviews in
                self.reviews = mReviews
            }.store(in: &disposables)
    }
    
    func likeService(userId: String, serviceId: String, onFinished: @escaping () -> Void) {
        serviceUseCase
            .likeService(userId: userId, serviceId: serviceId)
            .sink { _ in } receiveValue: { result in
                onFinished()
            }.store(in: &disposables)
    }
    
    func addServiceToExistingEvent(
        eventId: String,
        serviceId: String,
        onFinished: @escaping (Bool, String) -> Void
    ) {
        eventUseCase
            .addServiceToEvent(eventId: eventId, serviceId: serviceId)
            .sink { result in
                switch result {
                case .finished:
                    onFinished(true, "")
                case .failure(let error):
                    onFinished(false, error.localizedDescription)
                }
            } receiveValue: { _ in }.store(in: &disposables)
    }
    
    func createEventByClient(
        clientId: String,
        eventId: String,
        questions: FirstQuestions,
        onSuccess: @escaping (CreateEventResponse) -> Void,
        onFailure: @escaping (ErrorResponse) -> Void
    ) {
        eventUseCase
            .createEventByClient(clientId: clientId, eventId: eventId, questions: questions)
            .sink { _ in } receiveValue: { result in
                switch result {
                case .success(let createEventResponse):
                    onSuccess(createEventResponse)
                case .failure(let error):
                    onFailure(ErrorResponse(message: error.localizedDescription, status: 500))
                }
            }.store(in: &disposables)
    }
    
    func getLikedStrings(screenInfo: ScreenInfo?) -> String {
        let preList = "\(screenInfo?.serviceCategory?.name ?? "") - \(screenInfo?.serviceType?.name ?? "") - \(screenInfo?.subService?.name ?? "")"
        return preList.replacingOccurrences(of: "  -", with: "")
    }
    
    func getSubService(service: Service) -> SubService? {
        if service.id_sub_service_type != nil {
            var subService: SubService? = SubService(id: service.id_sub_service_type!)
            if service.id_sub_service_type == nil {
                subService = nil
            }
            return subService
        } else {
            return nil
        }
    }
    
    func getServiceType(service: Service) -> ServiceType? {
        if service.id_service_type != nil {
            var serviceType: ServiceType? = ServiceType(id: service.id_service_type!)
            if service.id_service_type == nil {
                serviceType = nil
            }
            return serviceType
        } else {
            return nil
        }
    }
    
    func getServiceCategory(service: Service) -> ServiceCategory? {
        var serviceCategory: ServiceCategory? = ServiceCategory(id: service.id_service_category)
        if service.id_service_category.isEmpty {
            serviceCategory = nil
        }
        return serviceCategory
    }
    
    func getScreenInfo2(service: Service) -> ScreenInfo {
        let subService = getSubService(service: service)
        let serviceType = getServiceType(service: service)
        let serviceCategory = getServiceCategory(service: service)
        
        return ScreenInfo(
            role: Role.Provider,
            startedScreen: Screen.EditServiceProvider,
            prevScreen: Screen.EditServiceProvider,
            event: Event(id: ""),
            questions: nil,
            serviceCategory: serviceCategory,
            clientEventId: nil,
            serviceType: serviceType,
            subService: subService,
            service: service
        )
    }
}
