//
//  FirebaseUserDb.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct FirebaseUserDb: FirebaseModel, Codable, Hashable {
    var id: String?
    let address: String?
    let business_name: String?
    let country: String?
    let role: String?
    let city: String?
    let facebook: String?
    let verified: Bool?
    let last_name: String?
    let likes: [String]?
    let lat: String?
    let lng: String?
    let instagram: String?
    let cp: String?
    let rfc: String?
    let street: String?
    let tiktok: String?
    let name: String?
    let files: [String]?
    let phone_one: String?
    let phone_two: String?
    let photo: String?
    let state: String?
    let events: [String]?
    let email: String?
    let uid: String?

    init(id: String = "", address: String? = "", business_name: String, country: String, role: String, city: String, facebook: String, verified: Bool, last_name: String, likes: [String]? = nil, lat: String? = "", lng: String? = "", instagram: String, cp: String, rfc: String, street: String, tiktok: String, name: String, files: [String]? = nil, phone_one: String, phone_two: String?, photo: String?, state: String, events: [String]? = nil, email: String, uid: String) {
        self.id = id
        self.address = address
        self.business_name = business_name
        self.country = country
        self.role = role
        self.city = city
        self.facebook = facebook
        self.verified = verified
        self.last_name = last_name
        self.likes = likes
        self.lat = lat
        self.lng = lng
        self.instagram = instagram
        self.cp = cp
        self.rfc = rfc
        self.street = street
        self.tiktok = tiktok
        self.name = name
        self.files = files
        self.phone_one = phone_one
        self.phone_two = phone_two
        self.photo = photo
        self.state = state
        self.events = events
        self.email = email
        self.uid = uid
    }

    init() {
        self.init(id: "", business_name: "", country: "", role: "Unauthenticated", city: "", facebook: "", verified: false, last_name: "", instagram: "", cp: "", rfc: "", street: "", tiktok: "", name: "", phone_one: "", phone_two: "", photo: "", state: "", email: "", uid: "")
    }
}
