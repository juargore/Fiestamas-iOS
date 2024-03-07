//
//  ServiceProviderData.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct ServiceProviderData: Codable, Hashable {
    let name: String
    let addressData: AddressData?
    let description: String
    let minCapacity: String
    let maxCapacity: String
    let cost: String
    let unit: String
    let attributes: [String]

    init(name: String, addressData: AddressData?, description: String, minCapacity: String, maxCapacity: String, cost: String, unit: String, attributes: [String]) {
        self.name = name
        self.addressData = addressData
        self.description = description
        self.minCapacity = minCapacity
        self.maxCapacity = maxCapacity
        self.cost = cost
        self.unit = unit
        self.attributes = attributes
    }
}

struct AddressData: Codable, Hashable {
    var address: String
    var city: String
    var state: String
    var postalCode: String
    var country: String
    var latitude: String
    var longitude: String

    init(address: String, city: String, state: String, postalCode: String, country: String, latitude: String, longitude: String) {
        self.address = address
        self.city = city
        self.state = state
        self.postalCode = postalCode
        self.country = country
        self.latitude = latitude
        self.longitude = longitude
    }
}
