//
//  UserRequest.swift
//  Fiestaki
//
//  Created by Arturo Gomez on 11/7/23.
//

import Foundation

struct UserRequest: Codable, Hashable {
    let role: String
    let name: String
    let last_name: String
    let phone_one: String
    let phone_two: String
    let email: String
    let password: String
}

struct UserRequestEdit: Codable, Hashable {
    let name: String
    let email: String
    let phone_one: String
    let phone_two: String
    let last_name: String
    let photo: String
}
