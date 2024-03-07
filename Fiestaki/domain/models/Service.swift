//
//  Service.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct Service: FirebaseModel, Codable, Hashable {
    var id: String?
    let active: Bool?
    let address: String
    let attributes: [String]?
    let description: String?
    let icon: String?
    let id_provider: String
    let id_service_category: String
    let id_service_type: String?
    let id_sub_service_type: String?
    let image: String
    let images: [String]?
    let lat: String?
    let lng: String?
    let max_attendees: Int
    let min_attendees: Int
    let name: String
    let name_service_category: String?
    let name_service_type: String?
    let name_sub_service_type: String?
    let price: Int
    let provider_name: String
    let rating: Int
    let unit: String?
    let videos: [String]?

    init(id: String, active: Bool? = true, address: String, attributes: [String]? = nil, description: String, icon: String?, id_provider: String, id_service_category: String, id_service_type: String? = "", id_sub_service_type: String? = "", image: String, images: [String]? = nil, lat: String?, lng: String?, max_attendees: Int, min_attendees: Int, name: String, name_service_category: String? = "", name_service_type: String? = "", name_sub_service_type: String? = "", price: Int, provider_name: String, rating: Int, unit: String? = nil, videos: [String]? = nil) {
        self.id = id
        self.active = active
        self.address = address
        self.attributes = attributes
        self.description = description
        self.icon = icon
        self.id_provider = id_provider
        self.id_service_category = id_service_category
        self.id_service_type = id_service_type
        self.id_sub_service_type = id_sub_service_type
        self.image = image
        self.images = images
        self.lat = lat
        self.lng = lng
        self.max_attendees = max_attendees
        self.min_attendees = min_attendees
        self.name = name
        self.name_service_category = name_service_category
        self.name_service_type = name_service_type
        self.name_sub_service_type = name_sub_service_type
        self.price = price
        self.provider_name = provider_name
        self.rating = rating
        self.unit = unit
        self.videos = videos
    }
    
    init(id: String, name: String) {
        self.id = id
        self.active = true
        self.address = ""
        self.attributes = []
        self.description = ""
        self.icon = ""
        self.id_provider = ""
        self.id_service_category = ""
        self.id_service_type = ""
        self.id_sub_service_type = ""
        self.image = ""
        self.images = []
        self.lat = ""
        self.lng = ""
        self.max_attendees = 0
        self.min_attendees = 0
        self.name = name
        self.name_service_category = ""
        self.name_service_type = ""
        self.name_sub_service_type = ""
        self.price = 0
        self.provider_name = ""
        self.rating = 0
        self.unit = ""
        self.videos = []
    }
}
