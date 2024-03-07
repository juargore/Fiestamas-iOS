//
//  MyPartyModels.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation
import FirebaseFirestore

struct MyPartyEventWithServices: Codable, Hashable {
    var event: MyPartyEvent?
    var servicesEvents: [MyPartyService]?

    init(event: MyPartyEvent? = nil, servicesEvents: [MyPartyService]? = nil) {
        self.event = event
        self.servicesEvents = servicesEvents
    }
}

struct MyPartyEvent: FirebaseModel, Codable, Hashable {
    var id: String?
    let attendees: String?
    let color_hex: String?
    let date: String?
    let id_client: String?
    let id_event_type: String?
    let location: String?
    let lat: String?
    let lng: String?
    let name: String?
    let name_event_type: String?
    let progressPercentage: Int?
    var finalCost: Int?
    var pendingDays: Int?
    var image: String?

    init(id: String, attendees: String, color_hex: String, date: String?, id_client: String, id_event_type: String, location: String, lat: String?, lng: String?, name: String, name_event_type: String, progressPercentage: Int? = nil, finalCost: Int? = nil, pendingDays: Int? = nil, image: String? = nil
    ) {
        self.id = id
        self.attendees = attendees
        self.color_hex = color_hex
        self.date = date
        self.id_client = id_client
        self.id_event_type = id_event_type
        self.location = location
        self.lat = lat
        self.lng = lng
        self.name = name
        self.name_event_type = name_event_type
        self.progressPercentage = progressPercentage
        self.finalCost = finalCost
        self.pendingDays = pendingDays
        self.image = image
    }
    
    func toEvent() -> Event {
        return Event(
            id: self.id_event_type ?? "",
            clientEventId: self.id ?? "",
            name: self.name_event_type ?? "",
            image: self.image ?? "",
            description: "",
            icon: "",
            pendingDays: self.pendingDays,
            index: 0,
            text_position: "",
            video: ""
        )
    }
}

struct MyPartyService: FirebaseModel, Codable, Hashable, Identifiable {
    var id: String?
    let address: String?
    let date: String?
    let description: String?
    var hex_color: String?
    let id_client: String?
    let id_client_event: String?
    let id_provider: String?
    let id_service_category: String?
    let id_service: String?
    let image: String?
    let name: String?
    let price: Int?
    let provider_contact_email: String?
    let provider_contact_name: String?
    let provider_contact_phone: String?
    let rating: Int?
    let service_category_name: String?
    let status: String?
    var serviceStatus: ServiceStatus?
    let event_data: EventData?
    
    init() {
        self.id = nil
        self.address = ""
        self.date = ""
        self.description = ""
        self.hex_color = ""
        self.id_client = ""
        self.id_client_event = "id_client_event"
        self.id_provider = "id_provider"
        self.id_service_category = "id_service_category"
        self.id_service = "id_service"
        self.image = "image"
        self.name = "name"
        self.price = 0
        self.provider_contact_email = "provider_contact_email"
        self.provider_contact_name = "provider_contact_name"
        self.provider_contact_phone = "provider_contact_phone"
        self.rating = 0
        self.service_category_name = "service_category_name"
        self.status = "status"
        self.serviceStatus = nil
        self.event_data = nil
    }

    init(id: String, address: String, date: String?, description: String, hex_color: String? = nil, id_client: String, id_client_event: String, id_provider: String, id_service_category: String, id_service: String, image: String, name: String, price: Int, provider_contact_email: String, provider_contact_name: String, provider_contact_phone: String, rating: Int, service_category_name: String? = nil, status: String, serviceStatus: ServiceStatus? = nil, event_data: EventData? = nil
    ) {
        self.id = id
        self.address = address
        self.date = date
        self.description = description
        self.hex_color = hex_color
        self.id_client = id_client
        self.id_client_event = id_client_event
        self.id_provider = id_provider
        self.id_service_category = id_service_category
        self.id_service = id_service
        self.image = image
        self.name = name
        self.price = price
        self.provider_contact_email = provider_contact_email
        self.provider_contact_name = provider_contact_name
        self.provider_contact_phone = provider_contact_phone
        self.rating = rating
        self.service_category_name = service_category_name
        self.status = status
        self.serviceStatus = serviceStatus
        self.event_data = event_data
    }
}

struct EventData: Codable, Hashable {
    let attendees: String?
    let color_hex: String?
    let date: String?
    let id_client: String?
    let id_event_type: String?
    let image: String?
    let lat: String?
    let lng: String?
    let location: String?
    let name: String?
    let name_event_type: String?

    init(attendees: String, color_hex: String, date: String?, id_client: String, id_event_type: String, image: String, lat: String? = nil, lng: String? = nil, location: String, name: String, name_event_type: String
    ) {
        self.attendees = attendees
        self.color_hex = color_hex
        self.date = date
        self.id_client = id_client
        self.id_event_type = id_event_type
        self.image = image
        self.lat = lat
        self.lng = lng
        self.location = location
        self.name = name
        self.name_event_type = name_event_type
    }
}

enum ServiceStatus: Codable, Hashable {
    case All
    case Hired
    case Pending
    case Canceled
}

struct BottomServiceStatus: Codable, Hashable {
    let status: ServiceStatus
    let name: String

    init(status: ServiceStatus, name: String) {
        self.status = status
        self.name = name
    }
}
