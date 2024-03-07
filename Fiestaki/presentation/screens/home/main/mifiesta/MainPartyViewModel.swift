//
//  MyPartyViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 7/26/23.
//

import Firebase
import SwiftUI
import CoreLocation
import Combine

final class MainPartyViewModel : ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    
    @Published var eventUseCase = EventUseCase()
    @Published var serviceUseCase = ServiceUseCase()
    @Published var messageUseCase = MessageUseCase()
    
    @Published var originalVerticalListClient = [MyPartyService]()
    @Published var originalParentListClient = [MyPartyEventWithServices]()
    @Published var horizontalListClient: [MyPartyEvent] = []
    @Published var verticalListClient: [MyPartyService] = []
    @Published var servicesListProvider: [MyPartyService] = []
    @Published var allServicesProvider: [Service] = []
    @Published var oneElementList: [MyPartyService] = []
    @Published var titleService: String = ""
    
    func getMyPartyServicesByProvider(providerId: String, onFinished: @escaping ([MyPartyService]) -> Void) {
        oneElementList.append(MyPartyService())
        eventUseCase
            .getMyPartyServicesByProvider(id: providerId)
            .sink { _ in } receiveValue: { list in
                var nList = [MyPartyService]()
                nList.append(MyPartyService())
                for service in list {
                    var nService = service
                    nService.serviceStatus = service.status!.getStatus()
                    nList.append(nService)
                }
                self.servicesListProvider = nList
                if nList.count > 1 {
                    let firstItem = nList[1]
                    self.titleService = "\(firstItem.service_category_name ?? "") - \(firstItem.name ?? "")"
                }
                onFinished(nList)
            }.store(in: &disposables)
    }
    
    func getEventsWithServices(id: String, onFinished: (() -> Void)? = nil) {
        eventUseCase
            .getMyPartyEventsWithServices(id: id)
            .sink { _ in } receiveValue: { parentList in
                self.originalParentListClient = parentList
                let (tempEventList, tempServiceList) = self.transformParentList(parentList)
                self.originalVerticalListClient = tempServiceList
                self.horizontalListClient = tempEventList
                self.verticalListClient = self.originalVerticalListClient
                onFinished?()
            }.store(in: &disposables)
    }
    
    func filterServiceListByEvent(eventId: String) {
        let parentList = originalParentListClient.filter { $0.event?.id == eventId }
        let (_, tempServiceList) = transformParentList(parentList)
        self.verticalListClient = tempServiceList
    }
    
    private func transformParentList(_ parentList: [MyPartyEventWithServices]) -> (events: [MyPartyEvent], services: [MyPartyService]) {
        var tempEventList = [MyPartyEvent]()
        var tempServiceList = [MyPartyService]()

        parentList.forEach { parentObject in
            if let event = parentObject.event {
                tempEventList.append(event)

                if let servicesEvents = parentObject.servicesEvents {
                    servicesEvents.forEach { service in
                        var nService = service
                        nService.serviceStatus = service.status!.getStatus()
                        tempServiceList.append(nService)
                    }
                }
            }
        }

        return (events: tempEventList, services: tempServiceList)
    }
    
    func sortProviderServiceListByStatus(status: ServiceStatus, providerId: String) {
        if status == ServiceStatus.All {
            self.getMyPartyServicesByProvider(providerId: providerId) { service in }
        } else {
            let copyservicesListProvider = servicesListProvider
            servicesListProvider = copyservicesListProvider.sortByServiceStatus(status)
        }
    }
    
    func sortClientServiceListByStatus(status: ServiceStatus, clientId: String) {
        if status == ServiceStatus.All {
            self.getEventsWithServices(id: clientId)
        } else {
            let copyVerticalListClient = verticalListClient
            verticalListClient = copyVerticalListClient.sortByServiceStatus(status)
        }
    }
    
    func getServicesByProviderId(providerId: String) {
        serviceUseCase
            .getServicesByProviderId(id: providerId)
            .sink { _ in } receiveValue: { servicesList in
                self.allServicesProvider = servicesList
            }.store(in: &disposables)
    }
    
    func deleteServiceById(serviceId: String) {
        serviceUseCase
            .deleteServiceById(id: serviceId)
            .sink { _ in } receiveValue: { result in
                debugPrint("Service deleted:", result)
            }.store(in: &disposables)
    }
    
    func enableOrDisableService(serviceId: String) {
        serviceUseCase
            .enableOrDisableService(serviceId: serviceId)
            .sink { _ in } receiveValue: { result in
                debugPrint("Service disabled:", result)
            }.store(in: &disposables)
    }
}
