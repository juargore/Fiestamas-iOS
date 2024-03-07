//
//  ServicesViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/13/23.
//

import Foundation
import Combine
import SwiftUI

final class ServicesViewModel: ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    
    private let serviceUseCase = ServiceUseCase()
    
    @Published var servicesByType: [Service] = []
    @Published var onServiceProviderCreated: Bool? = nil
    @Published var mediaLinksAfterSuccessMediaUpload: ([String], [String]) = ([], [])
    
    func getServicesAccordingData(screenInfo: ScreenInfo, onError: @escaping (String) -> Void) {
        if (screenInfo.subService != nil) {
            getServicesBySubServiceTypeId(screenInfo.subService!.id!)
        } else if (screenInfo.serviceType != nil) {
            getServicesByServiceTypeId(screenInfo.serviceType!.id!)
        } else {
            if screenInfo.serviceCategory?.id != nil {
                getServicesByServiceCategoryId(screenInfo.serviceCategory!.id!)
            } else {
                onError("Error: Id es nil!")
            }
        }
    }
    
    func getServicesByServiceCategoryId(_ serviceCategoryId: String) {
        serviceUseCase
            .getServicesOptionsByServiceCategoryId(id: serviceCategoryId)
            .sink { result in
                switch result {
                case .finished:
                    debugPrint("AQUI: Termino")
                case .failure(let error):
                    debugPrint("AQUI: Error: ", error)
                }
            } receiveValue: { services in
                var fServices = [Service]()
                services.forEach { service in
                    if service.active == true {
                        fServices.append(service)
                    }
                }
                self.servicesByType = fServices
            }.store(in: &disposables)
    }
    
    func getServicesByServiceTypeId(_ serviceTypeId: String) {
        serviceUseCase
            .getServicesOptionsByServiceTypeId(id: serviceTypeId)
            .sink { result in
                switch result {
                case .finished:
                    debugPrint("AQUI: Termino")
                case .failure(let error):
                    debugPrint("AQUI: Error: ", error)
                }
            } receiveValue: { services in
                var fServices = [Service]()
                services.forEach { service in
                    if service.active == true {
                        fServices.append(service)
                    }
                }
                self.servicesByType = fServices
            }.store(in: &disposables)
    }
    
    func getServicesBySubServiceTypeId(_ subServiceTypeId: String) {
        serviceUseCase
            .getServicesOptionsBySubServiceId(id: subServiceTypeId)
            .sink { result in
                switch result {
                case .finished:
                    debugPrint("AQUI: Termino")
                case .failure(let error):
                    debugPrint("AQUI: Error: ", error)
                }
            } receiveValue: { services in
                var fServices = [Service]()
                services.forEach { service in
                    if service.active == true {
                        fServices.append(service)
                    }
                }
                self.servicesByType = fServices
            }.store(in: &disposables)
    }
    
    
    func getLikedStrings(screenInfo: ScreenInfo) -> String {
        let preList = "\(screenInfo.serviceCategory?.name ?? "") - \(screenInfo.serviceType?.name ?? "") - \(screenInfo.subService?.name ?? "")"
        return preList.replacingOccurrences(of: "  -", with: "")
    }
    
    func getAttributesByServiceCategoryId(serviceCategoryId: String, onCompleted: @escaping ([Attribute]) -> Void) {
        serviceUseCase
            .getAttributesByServiceCategoryId(id: serviceCategoryId)
            .sink { _ in } receiveValue: { attributes in
                onCompleted(attributes)
            }.store(in: &disposables)
    }
    
    func getAttributesByServiceTypeId(serviceTypeId: String, onCompleted: @escaping ([Attribute]) -> Void) {
        serviceUseCase
            .getAttributesByServiceTypeId(id: serviceTypeId)
            .sink { _ in } receiveValue: { attributes in
                onCompleted(attributes)
            }.store(in: &disposables)
    }
    
    func getAttributesBySubServiceId(subServiceId: String, onCompleted: @escaping ([Attribute]) -> Void) {
        serviceUseCase
            .getAttributesBySubServiceId(id: subServiceId)
            .sink { _ in } receiveValue: { attributes in
                onCompleted(attributes)
            }.store(in: &disposables)
    }
    
    func createServiceForProvider(request: AddServiceProviderRequest, onFinished: @escaping (Bool) -> Void) {
        serviceUseCase
            .createServiceForProvider(request: request)
            .sink { _ in } receiveValue: { result in
                switch result {
                case .success(let success):
                    onFinished(success)
                case .failure(_):
                    onFinished(false)
                }
            }.store(in: &disposables)
    }
    
    func uploadMediaFilesIfNecessary(
        images: [UriFile],
        videos: [UriFile],
        isEditing: Bool,
        onFilesUploaded: @escaping ([String], [String]) -> Void
    ) {
        if !isEditing {
            serviceUseCase
                .uploadMediaFiles(images: images, videos: videos)
                .sink { _ in } receiveValue: { result in
                    onFilesUploaded(result.firstList, result.secondList)
                }.store(in: &disposables)
        } else {
            var alreadySentImages: [UriFile] = []
            var notSentImages: [UriFile] = []
            images.forEach { image in
                if image.uri.path.contains("fiestaki-1") {
                    alreadySentImages.append(image)
                } else {
                    notSentImages.append(image)
                }
            }
            
            var alreadySentVideos: [UriFile] = []
            var notSentVideos: [UriFile] = []
            videos.forEach { video in
                if video.uri.path.contains("fiestaki-1") {
                    alreadySentVideos.append(video)
                } else {
                    notSentVideos.append(video)
                }
            }
            
            if notSentImages.isEmpty && notSentVideos.isEmpty {
                let imagesUrl = alreadySentImages.map { $0.url ?? "" }
                let videosUrl = alreadySentVideos.map { $0.url ?? "" }
                onFilesUploaded(imagesUrl, videosUrl)
            } else {
                serviceUseCase
                    .uploadMediaFiles(images: notSentImages, videos: notSentVideos)
                    .sink { _ in } receiveValue: { result in
                        onFilesUploaded(result.firstList, result.secondList)
                    }.store(in: &disposables)
            }
        }
    }
    
    func updateServiceForProvider(serviceId: String, request: UpdateServiceProviderRequest, onFinished: @escaping (Bool) -> Void) {
        serviceUseCase
            .updateServiceForProvider(serviceId: serviceId, request: request)
            .sink { _ in } receiveValue: { result in
                switch result {
                case .success(let success):
                    onFinished(success)
                case .failure(_):
                    onFinished(false)
                }
            }.store(in: &disposables)
    }
    
    func getStartSelected(_ isEditing: Bool, _ service: Service?, _ attribute: Attribute) -> Bool {
        return isEditing && service?.attributes?.contains(attribute.id!) == true
    }
}
