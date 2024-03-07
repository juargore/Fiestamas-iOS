//
//  ProviderRequest.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct ProviderRequest: Codable, Hashable {
    let role: String
    let name: String
    let email: String
    let phone_one: String
    let phone_two: String
    let business_name: String
    let state: String
    let city: String
    let cp: String
    let rfc: String
    let country: String
    let password: String
    let last_name: String
    let lat: String
    let lng: String
    //let address: String
}

struct ProviderRequestEdit: Codable, Hashable {
    let name: String
    let last_name: String
    let email: String
    let phone_one: String
    let phone_two: String
    let photo: String
    let rfc: String
    let address: String
    let state: String
    let city: String
    let cp: String
    let country: String
    let lat: String
    let lng: String
}
