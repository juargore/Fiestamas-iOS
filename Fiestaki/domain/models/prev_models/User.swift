//
//  User.swift
//  Fiestaki
//
//  Created by Miguel Aquino on 18/05/23.
//

import Foundation

struct UserLogin: Codable {
    let id: String?
    let email: String?
    let displayName: String?
}

struct User: Codable {
    let uid: String?
    let email: String?
    let name: String?
    let last_name: String?
    let role: String?
    let phone_one: String?
}
