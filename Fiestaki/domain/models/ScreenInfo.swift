//
//  ScreenInfo.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct ScreenInfo: Codable, Hashable {
    var role: Role
    let startedScreen: Screen
    var prevScreen: Screen
    let event: Event?
    let questions: FirstQuestions?
    let serviceCategory: ServiceCategory?
    let clientEventId: String?
    let serviceType: ServiceType?
    let subService: SubService?
    var service: Service?

    init(role: Role, startedScreen: Screen, prevScreen: Screen, event: Event?, questions: FirstQuestions?, serviceCategory: ServiceCategory?, clientEventId: String?, serviceType: ServiceType? = nil, subService: SubService? = nil, service: Service? = nil
    ) {
        self.role = role
        self.startedScreen = startedScreen
        self.prevScreen = prevScreen
        self.event = event
        self.questions = questions
        self.serviceCategory = serviceCategory
        self.clientEventId = clientEventId
        self.serviceType = serviceType
        self.subService = subService
        self.service = service
    }
}

enum Role: String, Codable, Hashable {
    case Client
    case Provider
    case Unauthenticated
}

enum Screen: String, Codable, Hashable {
    case Home
    case Mifiesta
    case ServiceCategories
    case ServiceTypes
    case SubServices
    case EditServiceProvider
    case None
}

