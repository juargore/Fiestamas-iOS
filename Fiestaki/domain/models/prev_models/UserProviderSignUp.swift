//
//  UserProviderSignUp.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 22/05/23.
//

import Foundation

struct UserProviderSignUp: Encodable {
    let role: String
    let name: String
    let last_name: String
    let phone_one: String
    let business_name: String
    let state: String
    let city: String
    let cp: String
    let rfc: String
    let country: String
    let phone_two: String
    let email: String
    let password: String
    let lat: String
    let long: String
}
