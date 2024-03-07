//
//  AddServiceProviderRequest.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct AddServiceProviderRequest: Codable, Hashable {
    let id_service_category: String
    let id_service_type: String
    let id_sub_service_type: String
    let id_provider: String
    let provider_name: String
    let name: String
    let description: String
    let icon: String
    let image: String
    let rating: Int
    let min_attendees: Int
    let max_attendees: Int
    let price: String
    let attributes: [String]
    let images: [String]
    let videos: [String]
    let unit: String
    let address: String
    let lat: String
    let lng: String

    init(id_service_category: String, id_service_type: String, id_sub_service_type: String, id_provider: String, provider_name: String, name: String, description: String, icon: String, image: String, rating: Int, min_attendees: Int, max_attendees: Int, price: String, attributes: [String], images: [String], videos: [String], unit: String, address: String, lat: String, lng: String) {
        self.id_service_category = id_service_category
        self.id_service_type = id_service_type
        self.id_sub_service_type = id_sub_service_type
        self.id_provider = id_provider
        self.provider_name = provider_name
        self.name = name
        self.description = description
        self.icon = icon
        self.image = image
        self.rating = rating
        self.min_attendees = min_attendees
        self.max_attendees = max_attendees
        self.price = price
        self.attributes = attributes
        self.images = images
        self.videos = videos
        self.unit = unit
        self.address = address
        self.lat = lat
        self.lng = lng
    }
}

struct UpdateServiceProviderRequest: Codable, Hashable {
    let name: String
    let description: String
    //let image: String
    let min_attendees: Int
    let max_attendees: Int
    let price: String
    //let attributes: [String]
    let images: [String]
    let videos: [String]
    let unit: String
    let address: String
    let lat: String
    let lng: String

    init(name: String, description: String, min_attendees: Int, max_attendees: Int, price: String, images: [String], videos: [String], unit: String, address: String, lat: String, lng: String) {
        self.name = name
        self.description = description
        //self.image = image
        self.min_attendees = min_attendees
        self.max_attendees = max_attendees
        self.price = price
        //self.attributes = attributes
        self.images = images
        self.videos = videos
        self.unit = unit
        self.address = address
        self.lat = lat
        self.lng = lng
    }
}
