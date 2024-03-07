//
//  PlaceAutocomplete.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct PlaceAutocomplete: Codable, Hashable {
    let placeId: String
    let primaryText: String
    let secondaryText: String
    let fullAddress: String
}

struct Address: Codable, Hashable {
    var city: String?
    var country: String?
    var line1: String?
    var location: Location?
    var state: String?
    var zipcode: String?
}

struct Location: Codable, Hashable {
    var lat: String
    var lng: String
}
