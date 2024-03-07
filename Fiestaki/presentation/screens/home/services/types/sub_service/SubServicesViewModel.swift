//
//  SubServicesViewModel.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/13/23.
//

import Foundation
import SwiftUI
import Combine

final class SubServicesViewModel: ObservableObject {
    
    private var disposables = Set<AnyCancellable>()
    private let serviceUseCase = ServiceUseCase()
    
    @Published var subServices: [SubService] = []
    
    func getSubServicesByServiceTypeId(serviceTypeId: String) {
        serviceUseCase
            .getSubServicesByServiceTypeId(id: serviceTypeId)
            .sink { _ in} receiveValue: { subServices in
                self.subServices = subServices
            }.store(in: &disposables)
    }
    
    func getLikedStrings(screenInfo: ScreenInfo) -> String {
        let preList = "\(screenInfo.serviceCategory?.name ?? "") - \(screenInfo.serviceType?.name ?? "")"
        return preList.replacingOccurrences(of: "  -", with: "")
    }
    
    func getNewScreenInfo(
        screenInfo: ScreenInfo,
        subService: SubService?
    ) -> ScreenInfo {
        return ScreenInfo(
            role: screenInfo.role,
            startedScreen: screenInfo.startedScreen,
            prevScreen: Screen.SubServices,
            event: screenInfo.event,
            questions: screenInfo.questions,
            serviceCategory: screenInfo.serviceCategory,
            clientEventId: screenInfo.clientEventId,
            serviceType: screenInfo.serviceType,
            subService: subService
        )
    }
}
