//
//  FirebaseProviderDb.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct FirebaseProviderDb: Codable, Hashable {
    let business_name: String
    let country: String
    let role: String
    let city: String
    let verified: Bool
    let last_name: String
    let services: [String]
    let cp: String
    let rfc: String
    let street: String
    let name: String
    let files: [String]
    let attributes: [String]
    let phone_one: String
    let state: String
    let email: String
    let uid: String
}
